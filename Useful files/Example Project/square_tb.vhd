
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity square_tb is
--  Port ( );
end square_tb;

architecture Behavioral of square_tb is
component square is
    Port ( i_clk : in STD_LOGIC;
           i_res : in STD_LOGIC;
           i_start : in STD_LOGIC;
           o_done : out STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_data : out STD_LOGIC_VECTOR (7 downto 0);
           o_addr : out STD_LOGIC_VECTOR (1 downto 0);
           o_en : out STD_LOGIC;
           o_we : out STD_LOGIC);
end component;
signal i_clk : STD_LOGIC;
signal i_res : STD_LOGIC;
signal i_start : STD_LOGIC;
signal o_done : STD_LOGIC;
signal i_data : STD_LOGIC_VECTOR (7 downto 0);
signal o_data : STD_LOGIC_VECTOR (7 downto 0);
signal o_addr : STD_LOGIC_VECTOR (1 downto 0);
signal o_en : STD_LOGIC;
signal o_we : STD_LOGIC;
begin
    TOP0 : square port map(
        i_clk,
        i_res,
        i_start,
        o_done,
        i_data,
        o_data,
        o_addr,
        o_en,
        o_we
    );
    
    i_data <= "00000011";
    
    process
    begin
        wait for 10 ns;
        i_clk <= '1';
        wait for 10 ns;
        i_clk <= '0';
    end process;
    
    process
    begin
        i_start <= '0';
        i_res <= '1';
        wait for 10 ns;
        i_res <= '0';
        wait for 20 ns;
        i_start <= '1';
        wait for 20 ns;
        i_start <= '0';
        wait for 200 ns;
        assert false report "simulation ended" severity failure;
    end process;

end Behavioral;
