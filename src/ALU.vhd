
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    Port (
        i_A     : in  STD_LOGIC_VECTOR (7 downto 0);
        i_B     : in  STD_LOGIC_VECTOR (7 downto 0);
        i_op    : in  STD_LOGIC_VECTOR (2 downto 0);
        o_result: out STD_LOGIC_VECTOR (7 downto 0);
        o_flags : out STD_LOGIC_VECTOR (3 downto 0)  -- NZCV
    );
end alu;

architecture Behavioral of alu is
    signal result : STD_LOGIC_VECTOR(7 downto 0);
    signal n, z, c, v : STD_LOGIC;
begin
    process(i_A, i_B, i_op)
        variable temp : unsigned(8 downto 0);
        variable a_signed, b_signed, r_signed : signed(7 downto 0);
    begin
        case i_op is
            when "000" => -- Add
                temp := ('0' & unsigned(i_A)) + ('0' & unsigned(i_B));
                result <= std_logic_vector(temp(7 downto 0));
                c <= temp(8);

                a_signed := signed(i_A);
                b_signed := signed(i_B);
                r_signed := signed(result);

                if (a_signed(7) = b_signed(7)) and (r_signed(7) /= a_signed(7)) then
                    v <= '1';
                else
                    v <= '0';
                end if;

            when "001" => -- Subtract
                temp := ('0' & unsigned(i_A)) - ('0' & unsigned(i_B));
                result <= std_logic_vector(temp(7 downto 0));
                c <= temp(8);  -- For subtraction, c=1 means no borrow

                a_signed := signed(i_A);
                b_signed := signed(i_B);
                r_signed := signed(result);

                if (a_signed(7) /= b_signed(7)) and (r_signed(7) /= a_signed(7)) then
                    v <= '1';
                else
                    v <= '0';
                end if;

            when "010" => -- AND
                result <= i_A and i_B;
                c <= '0';
                v <= '0';

            when "011" => -- OR
                result <= i_A or i_B;
                c <= '0';
                v <= '0';

            when others =>
                result <= (others => '0');
                c <= '0';
                v <= '0';
        end case;

        n <= result(7);
        if result = "00000000" then
            z <= '1';
        else
            z <= '0';
        end if;

        o_result <= result;
        o_flags  <= n & z & c & v; -- NZCV
    end process;
end Behavioral;
