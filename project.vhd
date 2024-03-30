
-- Nome: Samuele Giammusso

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is 
port ( 
--input del test
i_clk   : in std_logic; 
i_rst   : in std_logic; 
i_start : in std_logic; 
i_w     : in std_logic; 
--output
o_z0    : out std_logic_vector(7 downto 0); 
o_z1    : out std_logic_vector(7 downto 0); 
o_z2    : out std_logic_vector(7 downto 0); 
o_z3    : out std_logic_vector(7 downto 0); 
o_done  : out std_logic; 
--memoria
o_mem_addr : out std_logic_vector(15 downto 0); 
i_mem_data : in std_logic_vector(7 downto 0); 
o_mem_we   : out std_logic; 
o_mem_en   : out std_logic 
); 
end project_reti_logiche;

---------------------------   A)  PARTE DI BEHAVIOURAL
                        
architecture Behavioral of project_reti_logiche is
--INTERFACCIA DEL COMPONENTE:
component datapath is
        port ( 
        
        -- 1)I segnali che la macchina a stati usa per controllare il componente (sia i segnali in ingresso che in uscita)
        
        --input del test
        i_clk : in std_logic; 
        i_rst : in std_logic; 
        i_w : in std_logic; 
        --output
        o_z0 : out std_logic_vector(7 downto 0); 
        o_z1 : out std_logic_vector(7 downto 0); 
        o_z2 : out std_logic_vector(7 downto 0); 
        o_z3 : out std_logic_vector(7 downto 0); 
        o_done  : out std_logic;
        --memoria
        o_mem_addr : out std_logic_vector(15 downto 0); 
        i_mem_data : in std_logic_vector(7 downto 0);
        --registri
        r_load : in STD_LOGIC;         
        r_addr_load : in STD_LOGIC;
        r_i_0_load : in STD_LOGIC; 
        r_i_1_load : in STD_LOGIC;
        r_w_load : in STD_LOGIC;
        --multiplexer
        r_addr_sel : in STD_LOGIC;
        z_sel : in STD_LOGIC                    
        );
end component;

-- 2)I segnali della macchina a stati che servono nella funzione di uscita:
        
        --registri
        signal r_load : STD_LOGIC;          
        signal r_addr_load : STD_LOGIC;
        signal r_i_0_load : STD_LOGIC; 
        signal r_i_1_load : STD_LOGIC;
        signal r_w_load : STD_LOGIC;
        --multiplexer
        signal r_addr_sel : STD_LOGIC;
        signal z_sel : STD_LOGIC;        

-- 3)Gli stati S

        type S is (S0, S1, S2, S3, S4, S5, S6); 
        signal cur_state, next_state : S; 

begin
-- ISTANZIO IL COMPONENTE:
DATAPATH0: datapath port map( --Mapping dei segnali
        --input del test
        i_clk => i_clk,
        i_rst => i_rst,
        i_w => i_w,
        --output
        o_z0 => o_z0, 
        o_z1 => o_z1,
        o_z2 => o_z2, 
        o_z3 => o_z3, 
        o_done => o_done,
        --memoria
        o_mem_addr => o_mem_addr,
        i_mem_data  => i_mem_data,
        --registri
        r_load => r_load,         
        r_addr_load => r_addr_load,
        r_i_0_load => r_i_0_load, 
        r_i_1_load => r_i_1_load,
        r_w_load => r_w_load,
        --multiplexer
        r_addr_sel => r_addr_sel,
        z_sel => z_sel        
        );
        
--MACCHINA A STATI:

-- 1) reset o next_state

process(i_clk, i_rst)                  
    begin
        if(i_rst = '1') then
            cur_state <= S0;
        elsif i_clk'event and i_clk = '1' then
            cur_state <= next_state;
        end if;
    end process;

-- 2) funzione di stato prossimo

process(i_start, cur_state)
begin
    next_state <= cur_state;
    case cur_state is
        when S0 =>
            if i_start='1' then
                next_state<=S1;            
            end if;
        when S1 =>
            next_state<=S2;            
        when S2 =>
            if i_start='1' then
                next_state<=S3;
            elsif i_start='0' then
                next_state<=S4;
            end if;
        when S3 =>
            if i_start='0' then
                next_state<=S4;
            end if;
        when S4 =>
            next_state<=S5;
        when S5 =>
            next_state<=S6;
        when S6 =>
            if i_start='1' then
                next_state<=S1;
            else
                next_state<=S0;
            end if;        
    end case;
end process;

-- 3) funzione di uscita

process(cur_state)
begin
--prima assegno tutti i segnali cos  non inferisco dei latch
        
        --memoria
        o_mem_we <= '0';
        o_mem_en <= '0';    
        --registri                   
        r_load <= '0';        
        r_addr_load <= '0';
        r_i_0_load <= '0';
        r_i_1_load <= '0';
        r_w_load <= '1';
        --multiplexer
        r_addr_sel <= '0';        
        z_sel <= '0';              
--poi assegno i segnali che cambiano per ogni stato
        case cur_state is                
            when S0 =>                  --stato di reset  
                z_sel <= '0';
                r_load <= '0';                  
                o_mem_en <= '0';
                r_addr_load <= '0';
                r_i_0_load <= '0';
                r_i_1_load <= '0';
            when S1 =>                  --primo bit di uscita                
                z_sel <= '0';
                r_i_1_load <= '1';
                r_addr_sel <= '0';
                r_addr_load <= '1';
            when S2 =>                  --secondo bit di uscita
                r_i_1_load <= '0';
                r_i_0_load <= '1';
                r_addr_load <= '0';
            when S3 =>                  --somma e shift
                r_i_0_load <= '0';
                r_addr_sel <= '1';
                r_addr_load <= '1';
            when S4 =>                  --interrogo la memoria: ask-mem
                o_mem_en <= '1';
                r_addr_load <= '0';
                r_i_0_load <= '0';
            when S5 =>                  --leggo da memoria: read-mem
                r_load <= '1';                                            
            when S6 =>                  --fine
                o_mem_en <= '0';
                r_load <= '0';                
                z_sel <= '1';            
        end case;
end process; 

end Behavioral;

---------------------------   B) PARTE DI DATAPATH

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath is
        port ( 
        
        -- 1)I segnali che la macchina a stati usa per controllare il componente (sia i segnali in ingresso che in uscita)
        
        --input del test
        i_clk : in std_logic; 
        i_rst : in std_logic; 
        i_w : in std_logic; 
        --output
        o_z0 : out std_logic_vector(7 downto 0); 
        o_z1 : out std_logic_vector(7 downto 0); 
        o_z2 : out std_logic_vector(7 downto 0); 
        o_z3 : out std_logic_vector(7 downto 0); 
        o_done  : out std_logic;
        --memoria
        o_mem_addr : out STD_LOGIC_VECTOR (15 downto 0); 
        i_mem_data : in STD_LOGIC_VECTOR (7 downto 0);
        --registri
        r_load : in STD_LOGIC;          
        r_addr_load : in STD_LOGIC;
        r_i_0_load : in STD_LOGIC; 
        r_i_1_load : in STD_LOGIC;
        r_w_load : in STD_LOGIC;
        --multiplexer
        r_addr_sel : in STD_LOGIC;
        z_sel : in STD_LOGIC 
        );  
end datapath;
           
-- 2)I segnali dei componenti interni

architecture Behavioral of datapath is 
    --registri
    signal o_reg0 : STD_LOGIC_VECTOR (7 downto 0);
    signal o_reg1 : STD_LOGIC_VECTOR (7 downto 0);
    signal o_reg2 : STD_LOGIC_VECTOR (7 downto 0);
    signal o_reg3 : STD_LOGIC_VECTOR (7 downto 0);
    signal o_reg_addr : STD_LOGIC_VECTOR (15 downto 0);
    signal o_reg_i : STD_LOGIC_VECTOR (1 downto 0);  
    signal o_reg_w : STD_LOGIC;
    --somma
    signal sum : STD_LOGIC_VECTOR(15 downto 0);
    --zero padding
    signal padded : STD_LOGIC_VECTOR(15 downto 0);
    --left shifter
    signal shifter : STD_LOGIC_VECTOR(15 downto 0);
    --multiplexer
    signal mux_reg_addr : STD_LOGIC_VECTOR (15 downto 0);
    --decoder
    signal o_dec : STD_LOGIC_VECTOR (3 downto 0); 

-- 3)Definisco tutte le parti che compongono il circuito: registri, sommatori, multiplexer ...ecc 

begin

    --Registro reg_w
        process(i_clk, i_rst)    
            begin
                if i_clk'event and i_clk = '1' then  
                    if (r_w_load = '1') then
                        o_reg_w <= i_w;                
                    end if;
                end if;
            end process;

    --Registro reg_input_1
        process(i_clk, i_rst)    
            begin
                if(i_rst = '1') then
                    o_reg_i(1) <= 'X';
                elsif i_clk'event and i_clk = '1' then  
                    if (r_i_1_load = '1') then
                        o_reg_i(1) <= o_reg_w;                
                    end if;
                end if;
            end process;
                    
    --Registro reg_input_0
        process(i_clk, i_rst)    
        begin
            if(i_rst = '1') then
                o_reg_i(0) <= 'X';
            elsif i_clk'event and i_clk = '1' then  
                if (r_i_0_load = '1') then
                    o_reg_i(0) <= o_reg_w;                
                end if;
            end if;
        end process;       
            
    --Left Shifter
        shifter <= o_reg_addr(14 downto 0) & '0';
        
    --Zero Padding dei leftmost-bits
        padded <= "000000000000000" & o_reg_w;
            
    --Sommatore
        sum <= padded + shifter;
                    
    --Multiplexer di reg_addr
    with r_addr_sel select                                
            mux_reg_addr <= sum when '1',
                            "0000000000000000" when '0',
                            "XXXXXXXXXXXXXXXX" when others;
                      
    --Registro addr
        process(i_clk, i_rst)    
        begin
            if(i_rst = '1') then
                o_reg_addr <= "0000000000000000";
            elsif i_clk'event and i_clk = '1' then  
                if (r_addr_load = '1') then
                    o_reg_addr <= mux_reg_addr;                 
                end if;
            end if;
        end process;        
    
    --Interrogo la memoria
    o_mem_addr <= o_reg_addr;    
    
    --Decoder
    with o_reg_i select
        o_dec <= "0001" when "00",
                 "0010" when "01",
                 "0100" when "10",
                 "1000" when "11",
                 "XXXX" when others;   
                                         
    --Registro 0
        process(i_clk, i_rst)    
        begin
            if(i_rst = '1') then
                o_reg0 <= "00000000";
            elsif i_clk'event and i_clk = '1' then  
                if (r_load = '1' and o_dec(0) = '1') then
                    o_reg0 <= i_mem_data;                
                end if;
            end if;
        end process;
        
    --Registro 1
        process(i_clk, i_rst)    
        begin
            if(i_rst = '1') then
                o_reg1 <= "00000000";
            elsif i_clk'event and i_clk = '1' then  
                if (r_load = '1' and o_dec(1) = '1') then
                    o_reg1 <= i_mem_data;                 
                end if;
            end if;
        end process;
        
    --Registro 2
        process(i_clk, i_rst)    
        begin
            if(i_rst = '1') then
                o_reg2 <= "00000000";
            elsif i_clk'event and i_clk = '1' then  
                if (r_load = '1' and o_dec(2) = '1') then
                    o_reg2 <= i_mem_data;                 
                end if;
            end if;
        end process;
        
    --Registro 3
        process(i_clk, i_rst)    
        begin
            if(i_rst = '1') then
                o_reg3 <= "00000000";
            elsif i_clk'event and i_clk = '1' then  
                if (r_load = '1' and o_dec(3) = '1') then
                    o_reg3 <= i_mem_data;                 
                end if;
            end if;
        end process;
        
    --Multiplexer di Z0
    with z_sel select                                
            o_z0 <= o_reg0 when '1',
                      "00000000" when '0',
                      "XXXXXXXX" when others;
                      
    --Multiplexer di Z1
    with z_sel select                                
            o_z1 <= o_reg1 when '1',
                      "00000000" when '0',
                      "XXXXXXXX" when others;
                      
    --Multiplexer di Z2
    with z_sel select                                
            o_z2 <= o_reg2 when '1',
                      "00000000" when '0',
                      "XXXXXXXX" when others;
                      
    --Multiplexer di Z3
    with z_sel select                                
            o_z3 <= o_reg3 when '1',
                      "00000000" when '0',
                      "XXXXXXXX" when others;
                      
    --Segnale di Fine
    o_done <= z_sel;
    
end Behavioral;
