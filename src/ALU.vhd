library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

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
    signal temp   : STD_LOGIC_VECTOR(8 downto 0);
    signal n, z, c, v : STD_LOGIC;
begin
    process(i_A, i_B, i_op)
    begin
        case i_op is
            when "000" => -- Add
                temp <= ('0' & i_A) + ('0' & i_B);
                result <= temp(7 downto 0);
                c <= temp(8);
                v <= (i_A(7) xor i_B(7)) xor result(7);
            when "001" => -- Subtract
                temp <= ('0' & i_A) - ('0' & i_B);
                result <= temp(7 downto 0);
                c <= temp(8);
                v <= (i_A(7) xor i_B(7)) xor result(7);
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
