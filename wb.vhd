----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:43:56 01/10/2021 
-- Design Name: 
-- Module Name:    wb_stage - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity wb_stage is
port(			clk:in std_logic ;
				memRD : in STD_LOGIC_VECTOR (4 downto 0);
				mem_memtoreg : in	STD_LOGIC;
				mem_regwrite:in std_logic;
				
				mem_res_of_alu: in  STD_LOGIC_VECTOR (31 downto 0);
           readdata : in  STD_LOGIC_VECTOR (31 downto 0);
			  wb_regwrite:out std_logic;
			  wbRD : out STD_LOGIC_VECTOR (4 downto 0);
			  WRITE_DATA	: out	STD_LOGIC_VECTOR (31 downto 0));
end wb_stage;

architecture Behavioral of wb_stage is

signal WRITE_DATA_d	: 	STD_LOGIC_VECTOR (31 downto 0);

begin
process(clk)
begin
	wbRD<=memRD;
	wb_regwrite<=mem_regwrite;
	WRITE_DATA<=WRITE_DATA_d;
end process;
	process(mem_memtoreg)
	begin
	if mem_memtoreg = '1' then
		WRITE_DATA_d<=readdata;
	else
		WRITE_DATA_d<=mem_res_of_alu;
		end if;
	
	end process;
process(clk)
begin
if rising_edge(clk) then
	wbRD<=memRD;
	wb_regwrite<=mem_regwrite;
	WRITE_DATA<=WRITE_DATA_d;
	end if;
end process;

end Behavioral;