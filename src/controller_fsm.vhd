library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity controller_fsm is
    Port (
        clk   : in  STD_LOGIC;
        reset : in  STD_LOGIC;
        adv   : in  STD_LOGIC;
        state : out STD_LOGIC_VECTOR (3 downto 0)
    );
end controller_fsm;

architecture Behavioral of controller_fsm is
    type state_type is (S0, S1, S2, S3);
    signal current_state, next_state : state_type;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= S0;
        elsif rising_edge(clk) then
            if adv = '1' then
                current_state <= next_state;
            end if;
        end if;
    end process;

    process(current_state)
    begin
        case current_state is
            when S0 => next_state <= S1;
            when S1 => next_state <= S2;
            when S2 => next_state <= S3;
            when S3 => next_state <= S0;
        end case;
    end process;

    process(current_state)
    begin
        case current_state is
            when S0 => state <= "0001";
            when S1 => state <= "0010";
            when S2 => state <= "0100";
            when S3 => state <= "1000";
        end case;
    end process;
end Behavioral;
