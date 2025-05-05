library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top_basys3 is
    Port (
        clk    : in  STD_LOGIC;
        btnU   : in  STD_LOGIC;
        btnC   : in  STD_LOGIC;
        sw     : in  STD_LOGIC_VECTOR(7 downto 0);
        op_sel : in  STD_LOGIC_VECTOR(2 downto 0);
        led    : out STD_LOGIC_VECTOR(15 downto 0)
    );
end top_basys3;

architecture Behavioral of top_basys3 is
    signal state        : STD_LOGIC_VECTOR(3 downto 0);
    signal A_reg, B_reg : STD_LOGIC_VECTOR(7 downto 0);
    signal result       : STD_LOGIC_VECTOR(7 downto 0);
    signal flags        : STD_LOGIC_VECTOR(3 downto 0);
begin
    FSM: entity work.controller_fsm
        port map (
            clk   => clk,
            reset => btnU,
            adv   => btnC,
            state => state
        );

    process(clk)
    begin
        if rising_edge(clk) then
            if state = "0010" then
                A_reg <= sw;
            elsif state = "0100" then
                B_reg <= sw;
            end if;
        end if;
    end process;

    ALU: entity work.alu
        port map (
            i_A     => A_reg,
            i_B     => B_reg,
            i_op    => op_sel,
            o_result=> result,
            o_flags => flags
        );

    led(15 downto 12) <= flags;
    led(11 downto 4)  <= result;
    led(3 downto 0)   <= state;
end Behavioral;
