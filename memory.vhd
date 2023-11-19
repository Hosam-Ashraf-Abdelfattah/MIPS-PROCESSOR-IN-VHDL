----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    07:17:07 01/10/2021 
-- Design Name: 
-- Module Name:    memory - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity memory is
	Port (  -- address : in  STD_LOGIC_VECTOR (31 downto 0);
				clk		: in	STD_LOGIC;
				ex_memread		: in	STD_LOGIC;
				ex_memtoreg		: in	STD_LOGIC;  
				ex_memwrite		: in	STD_LOGIC;
				ex_regwrite:in std_logic;
				excuteRD : in STD_LOGIC_VECTOR (4 downto 0);
				result : in std_logic_vector(31 downto 0);
            data_to_mem : in  STD_LOGIC_VECTOR (31 downto 0);
				----------------------------------------------------------------
				data_to_mem_simulation : out  STD_LOGIC_VECTOR (31 downto 0);
				-----------------------------------------------------------------
				
				
				memRD : out STD_LOGIC_VECTOR (4 downto 0);
				mem_memtoreg : out	STD_LOGIC;
				mem_regwrite:out std_logic;
				mem_res_of_alu: out  STD_LOGIC_VECTOR (31 downto 0);
           readdata : out  STD_LOGIC_VECTOR (31 downto 0));
end memory;

architecture Behavioral of memory is
signal readdata_d :   STD_LOGIC_VECTOR (31 downto 0);

type ram_16_x_32 is array(0 to 15) of std_logic_vector (31 downto 0);
	signal dm: ram_16_x_32 :=( x"00000000",
										x"00000000",
										x"00000000",
										x"00000000",
										x"00000000",
										x"00000000",
										x"00000000",
										x"00000000",
										x"00000000",
										x"00000000",
										x"00000000",
										x"00000000",
										x"00000000",
										x"00000000",
										x"00000000",
										x"00000000"
	
	
	);

begin

process(ex_memwrite,ex_memread)
begin
	if(ex_memwrite = '1')then
			dm((to_integer(unsigned(result)))/4) <= data_to_mem;
			end if;
	if(ex_memread = '1')then
		readdata_d <=	dm((to_integer(unsigned(result)))/4) ;
			end if;
end process;
process(clk)
begin
if rising_edge(clk) then


memRD<=excuteRD;
mem_regwrite<=ex_regwrite;
mem_res_of_alu<=result;
mem_memtoreg<=ex_memtoreg;
readdata <= readdata_d;
data_to_mem_simulation<=data_to_mem;
end if;
end process;


end Behavioral