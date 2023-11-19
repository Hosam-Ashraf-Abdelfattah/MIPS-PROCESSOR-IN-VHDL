library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;



entity execute is
	port(
	---------------------------------
	  -- control signal
	  clk:in std_logic ;
		 memread		: in	STD_LOGIC;
		 memtoreg		: in	STD_LOGIC;
   	 aluop		: in	STD_LOGIC_vector(1 downto 0);
		 memwrite		: in	STD_LOGIC;
		 alusrc		: in	STD_LOGIC;
		 mem_memtoreg : in	STD_LOGIC;
		 wb_regwrite : in	STD_LOGIC;
		 regwrite:in std_logic;
		 ----------------------------------
			  
		decodeRS : in	STD_LOGIC_VECTOR (4 downto 0);
		decodeRT : in	STD_LOGIC_VECTOR (4 downto 0);
		decodeRD : in	STD_LOGIC_VECTOR (4 downto 0);
		decodefunct: in	STD_LOGIC_VECTOR (5 downto 0);
		memRD : in	STD_LOGIC_VECTOR (4 downto 0);
		wbRD : in	STD_LOGIC_VECTOR (4 downto 0);
		memresult : in std_logic_vector(31 downto 0);
		WRITE_DATA : in std_logic_vector(31 downto 0);

	
		
		se_out_to_execut : in	STD_LOGIC_VECTOR (31 downto 0);
		a1 : in std_logic_vector(31 downto 0);
		a2 : in std_logic_vector(31 downto 0);
		------------------------------------------------------
		ex_memread_simulation		: out	STD_LOGIC;
		result_simulation : out std_logic_vector(31 downto 0);
		---------------------------------------
		
		ex_memread		: out	STD_LOGIC;
		ex_memtoreg		: out	STD_LOGIC;  
		ex_regwrite:out std_logic;
		ex_memwrite		: out	STD_LOGIC;
			  
		data_to_mem: out std_logic_vector(31 downto 0);
		excuteRD : out STD_LOGIC_VECTOR (4 downto 0);
		result : out std_logic_vector(31 downto 0));
end execute;

architecture Behavioral of execute is

 signal operation :   STD_LOGIC_VECTOR (3 downto 0);
 signal forward_a :   STD_LOGIC_VECTOR (1 downto 0);
 signal forward_b :   STD_LOGIC_VECTOR (1 downto 0);
 signal alu_surce_1: std_logic_vector(31 downto 0);
 signal alu_surce_2: std_logic_vector(31 downto 0);
 signal mux_1_out : std_logic_vector(31 downto 0);
 signal resultx : std_logic_vector(31 downto 0);
---------------------------------------------------------
--delay signals
signal result_d :  std_logic_vector(31 downto 0);



begin

-------------------------------------
--forwarding
process(wb_regwrite,mem_memtoreg)
begin
if memRD = decodeRS and (mem_memtoreg = '1' or wb_regwrite = '1') then
	forward_a<="10";
elsif wbRD = decodeRS and (mem_memtoreg = '1' or wb_regwrite = '1') then
	forward_a<="01";
else
	forward_a<="00";
end if ;

if memRD = decodeRD and (mem_memtoreg = '1' or wb_regwrite = '1') then
	forward_b<="10";
elsif wbRD = decodeRD and (mem_memtoreg = '1' or wb_regwrite = '1') then
	forward_b<="01";
else 
	forward_b<="00";
end if ;
	
end process;
--------------------------------------
--alu surce mux 1
process(alusrc)
begin
if alusrc = '0' then 
	mux_1_out <= a2;
else 
	mux_1_out <= se_out_to_execut ;
end if ;
end process;
----------------------------------
--mux 2
process(forward_a,forward_b)
begin
if forward_a ="00" then
	alu_surce_1<= a1;
elsif forward_a ="10" then
	alu_surce_1<= memresult;
elsif forward_a ="01" then
	alu_surce_1 <= WRITE_DATA;
end if;

if forward_b ="00" then
	alu_surce_2<= mux_1_out;
elsif forward_b ="10" then
	alu_surce_2<= memresult;
elsif forward_b ="01" then
	alu_surce_2 <= WRITE_DATA;
end if;
end process;
-----------------------------------
--aluop
process(decodefunct,aluop)
begin
	operation(3) <= '0';
	operation(2) <= aluop(0) or (aluop(1) and decodefunct(1));
	operation(1) <=  not aluop(1)  or not decodefunct(2);
	operation(0) <= (decodefunct(3) or decodefunct(0)) and aluop(1);
end process;
----------------------------------------------
process(alu_surce_1,alu_surce_2,a2,operation)
	begin
		case operation is
		when "0000"=>
			resultx <= a1 and a2;
		when "0001"=>
		resultx <= a1 or a2;
		when "0010"=>
		resultx <= std_logic_vector(unsigned(a1) + unsigned(a2));
		when "0011"=>
		resultx <= std_logic_vector(unsigned(a1) - unsigned(a2));
		when "0100"=>
		if (signed(a1) <signed(a2))then
			resultx <= x"00000001";
			else
			resultx <=x"00000000";
			end if;
		when "0101"=>
		resultx <= a1 or a2;
		when others=>null;
		result <=x"00000000";
	
	end case;
end process;
result_d <= resultx;
process(clk)
begin
if rising_edge(clk) then
ex_regwrite <= regwrite;
ex_memread		<=memread;
ex_memtoreg		<=  memtoreg;
ex_memwrite <= memwrite;
excuteRD <=decodeRD;
data_to_mem<=a2 ;
result<=result_d;
result_simulation<=result_d;
ex_memread_simulation <= memread;
end if;
end process;


end Behavioral;