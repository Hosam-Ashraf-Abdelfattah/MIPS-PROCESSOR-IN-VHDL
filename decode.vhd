library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;


entity decoding is
	port(  CLK 		: in	STD_LOGIC;				
	--	RESET		: in	STD_LOGIC;	
		
			  opcode	: in  	STD_LOGIC_VECTOR (5 downto 0);		 
	        RS_ADDR 	: in  	STD_LOGIC_VECTOR (4 downto 0);
	        RT_ADDR 	: in  	STD_LOGIC_VECTOR (4 downto 0);
	        RD_ADDR 	: in	STD_LOGIC_VECTOR (4 downto 0);
			  funct :  in  	STD_LOGIC_VECTOR (5 downto 0);
			  -----------------------------------------------
	        WRITE_DATA	: in	STD_LOGIC_VECTOR (31 downto 0);
			  wbRd		: in	STD_LOGIC_VECTOR (4 downto 0);
			  exRd		: in	STD_LOGIC_VECTOR (4 downto 0);
			  ofset		: in	STD_LOGIC_VECTOR (15 downto 0);
			  wb_regwrite:in std_logic;
			  READ_ADDR2 :in std_logic_vector (31 downto 0);
			  ex_memRead:in std_logic;
			  
			 -- jump		: out	STD_LOGIC;						
			 -- branch		: inout	STD_LOGIC;
			 -------------------------------------------------
			 --control signals
			  memread		: out	STD_LOGIC;
			  memtoreg		: out	STD_LOGIC;
			  aluop		: out	STD_LOGIC_vector(1 downto 0);
			  memwrite		: out	STD_LOGIC;
			  alusrc		: out	STD_LOGIC;	
			  regwrite:out std_logic;
			  pc_src:out std_logic;
			  -----------------------------------------------
			  pc_src_simulation :out std_logic;
			  refetch_simulation :out std_logic;
			  memread_simulation :out std_logic;
			  ex_memread_simulation2 : out std_logic;
			  opcode_simulation	: out  	STD_LOGIC_VECTOR (5 downto 0);
			------------------------------------------------	
				decodeRS : out	STD_LOGIC_VECTOR (4 downto 0);
				decodeRT : out	STD_LOGIC_VECTOR (4 downto 0);
				decodeRD : out	STD_LOGIC_VECTOR (4 downto 0);
				decodefunct: out	STD_LOGIC_VECTOR (5 downto 0);
			-----------------------------------------------------
				refetch :out std_logic;
				new_pc :out std_logic_vector (31 downto 0);
			----------------------------------------------------------
			  se_out_to_execut : out	STD_LOGIC_VECTOR (31 downto 0);
	        RS 		: out	STD_LOGIC_VECTOR (31 downto 0);
	        RT 		: out	STD_LOGIC_VECTOR (31 downto 0)	);
			  
end decoding;

architecture Behavioral of decoding is


  type REGS_T is array (31 downto 0) of STD_LOGIC_VECTOR(31 downto 0);

 
signal REGISTROS 	: REGS_T;	
signal regdst	: 	STD_LOGIC;
signal branch	: 	STD_LOGIC;
signal hazard	: 	STD_LOGIC;
signal  zero_f  : 	STD_LOGIC;
signal se_out	: 	STD_LOGIC_vector(31 downto 0);
signal sh_left	: 	STD_LOGIC_vector(31 downto 0);
signal br_adder	: 	STD_LOGIC_vector(31 downto 0);
signal RT_signal	: 	STD_LOGIC_vector(31 downto 0);
signal RS_signal	: 	STD_LOGIC_vector(31 downto 0);
--------------------------------------------
--delay signals
signal decodeRD_d : 	STD_LOGIC_VECTOR (4 downto 0);
signal se_out_to_execut_d : 	STD_LOGIC_VECTOR (31 downto 0);
signal refetch_d : std_logic;
signal new_pc_d : std_logic_vector (31 downto 0);
signal regwrite_d: std_logic;
signal alusrc_d	: 	STD_LOGIC;
signal memwrite_d		: 	STD_LOGIC;
signal aluop_d		: 	STD_LOGIC_vector(1 downto 0);
signal memtoreg_d		: 	STD_LOGIC;
signal memread_d		: 	STD_LOGIC;
signal pc_src_d: std_logic;
	
  
begin


	---------------------------------------------------------------
 --control unit
  process(opcode)
	begin
		if hazard = '0' then
		case opcode is 
		when "000000"=> -- and,or,add,sub
			regdst<='1';
		--	jump<='0';
		   pc_src_d<='0';
			branch<='0';
			memread_d<='0';
			memtoreg_d<='0';
			aluop_d<= "10";
			memwrite_d<='0';
			alusrc_d<='0';
			regwrite_d<='1' after 10 ns;
		when "100011"=> --load word
			regdst<='0';
		--	jump<='0';
			pc_src_d<='0';
			branch<='0';
			memread_d<='1';
			memtoreg_d<='1';
			aluop_d<= "00";
			memwrite_d<='0';
			alusrc_d<='1';
			regwrite_d<='1' after 10 ns;
		when "101011"=> --store word
			regdst<='0';
		--	jump<='0';
			pc_src_d<='0';
			branch<='0';
			memread_d<='0';
			memtoreg_d<='0';
			aluop_d<= "00";
			memwrite_d<='1';
			alusrc_d<='1';
			regwrite_d<='1' after 10 ns;
		when "000100"=> --branch equal
			regdst<='0';
		--	jump<='1';
			pc_src_d<='1';
			branch<='1' after 2 ns;
			memread_d<='0';
			memtoreg_d<='0';
			aluop_d<= "01";
			memwrite_d<='0';
			alusrc_d<='0';
			regwrite_d<='1' after 10 ns;
		when "000010"=> --jump
			regdst<='0';
			--jump<='1';
			pc_src_d<='1';
			branch<='0';
			memread_d<='0';
			memtoreg_d<='0';
			aluop_d<= "00";
			memwrite_d<='0';
			alusrc_d<='0';
			regwrite_d<='1' after 10 ns;
     when others => null;
			regdst<='0';
			--jump<='0';
			branch<='0';
			pc_src_d<='0';
			memread_d<='0';
			memtoreg_d<='0';
			aluop_d<= "00";
			memwrite_d<='0';
			alusrc_d<='0';
			regwrite_d<='0' after 10 ns;
	end case;
	else
		   regdst<='0';
			--jump<='0';
			branch<='0';
			pc_src_d<='0';
			memread_d<='0';
			memtoreg_d<='0';
			aluop_d<= "00";
			memwrite_d<='0';
			alusrc_d<='0';
			regwrite_d<='0' after 10 ns;
		end if;
		
end process;
------------------------------------------------------------------
-- sign extend and shift left
process(ofset)
begin
	se_out_to_execut_d(15 downto 0)<=ofset;
	se_out_to_execut_d(31 downto 16) <= (31 downto 16 =>ofset(15));
	
	se_out(1 downto 0)<=(1 downto 0 =>'0');
	se_out(17 downto 2)<=ofset;
	se_out(31 downto 18) <= (31 downto 18 =>ofset(15));
	br_adder	<=READ_ADDR2 + se_out ;
end process;
-----------------------------------------------------------------------

-- registers
process(wb_regwrite,WRITE_DATA,RD_ADDR)
	  begin
		--if  RESET='1' then
		--		for i in 0 to 31 loop
		--			REGISTROS(i) <= (others => '0');
		--		end loop;
				
				REGISTROS(0) <= "00000000000000000000000000000000";
				REGISTROS(1) <= "00000000000000000000000000000001";
				REGISTROS(2) <= "00000000000000000000000000000010";
				REGISTROS(3) <= "00000000000000000000000000000011";
				REGISTROS(4) <= "00000000000000000000000000000100";
				--REGISTROS(5) <= "00000000000000000000000000000101";
				REGISTROS(5) <= "00000000000000000000000000000001";
				--REGISTROS(6) <= "00000000000000000000000000000110";
				REGISTROS(6) <= "00000000000000000000000000000000";
				--REGISTROS(7) <= "00000000000000000000000000000111";
				REGISTROS(7) <= "00000000000000000000000000100000";
				--REGISTROS(8) <= "00000000000000000000000000001000";
				REGISTROS(8) <= "00000000000000000000000000000000";
				REGISTROS(9) <= "00000000000000000000000000001001";
				--REGISTROS(10) <= "00000000000000000000000000001010";
				REGISTROS(10) <= "00000000000000000000000000010011";
				--REGISTROS(11) <= "00000000000000000000000000001011";
				REGISTROS(11) <= "00000000000000000000000000011010";
				--REGISTROS(12) <= "00000000000000000000000000001100";
				REGISTROS(12) <= "00000000000000000000000000000000";
				REGISTROS(13) <= "00000000000000000000000000001101";
				REGISTROS(14) <= "00000000000000000000000000001110";
				REGISTROS(15) <= "00000000000000000000000000001111";
				REGISTROS(16) <= "00000000000000000000000000010000";
				REGISTROS(17) <= "00000000000000000000000000010001";
				REGISTROS(18) <= "00000000000000000000000000010010";
				REGISTROS(19) <= "00000000000000000000000000010011";
				REGISTROS(20) <= "00000000000000000000000000010100";
				REGISTROS(21) <= "00000000000000000000000000010101";
				REGISTROS(22) <= "00000000000000000000000000010110";
				REGISTROS(23) <= "00000000000000000000000000010111";
				REGISTROS(24) <= "00000000000000000000000000011000";
				REGISTROS(25) <= "00000000000000000000000000011001";
				REGISTROS(26) <= "00000000000000000000000000011010";
				REGISTROS(27) <= "00000000000000000000000000011011";
				REGISTROS(28) <= "00000000000000000000000000011100";
				REGISTROS(29) <= "00000000000000000000000000011101";
				REGISTROS(30) <= "00000000000000000000000000011110";
				REGISTROS(31) <= "00000000000000000000000000011111";
	--	elsif rising_edge(CLK) then
		
				if regdst ='1' then
					decodeRD_d<=RD_ADDR;
				else
					decodeRD_d<=RT_ADDR;
				end if;
				
				if  wb_regwrite='1' then
					REGISTROS(to_integer(unsigned(wbRd)))<=WRITE_DATA;
				end if;
			
			
		--end if;
	  end process;
	------------------------------------------------------------
  RS_signal <= (others=>'0') when RS_ADDR="00000"
         else REGISTROS(to_integer(unsigned(RS_ADDR)));
  RT_signal <= (others=>'0') when RT_ADDR="00000"
         else REGISTROS(to_integer(unsigned(RT_ADDR)));

			---------------------------------------------------------
	-- comparator
	process(RS_signal,RT_signal)
	begin
	if RS_signal = RT_signal then
		zero_f <= '1';
	else
		zero_f <= '0';
	end if ;
	end process;
	-------------------------------------------------------------------
	--pranch mux
process(zero_f)
begin
	if branch= '1' and zero_f='1' then
		new_pc_d <=br_adder;
	else
		new_pc_d <=READ_ADDR2;
	end if;
end process;
-----------------------------------------------------------------	
	-- hazard control
	process(ex_memRead)
	begin
	
	if (ex_memRead = '1') and ((exRd = RS_ADDR) or (exRd = RT_ADDR)) then
		hazard<='1';
		refetch_d<='1';
	elsif ex_memRead = '0' then
		hazard<='0';
		refetch_d<='0';
		end if;
	
	end process;
----------------------------------------------------------------------
process(clk)
begin
if rising_edge(clk) then
	se_out_to_execut<=se_out_to_execut_d;
	decodeRD<=decodeRD_d;
	decodeRS<=RS_ADDR;
	decodeRT<=RT_ADDR;
	decodefunct<= funct;
	RS<=RS_signal;
	RT<=RT_signal;
	refetch<=refetch_d;
	new_pc<=new_pc_d;
	regwrite<=regwrite_d;
	alusrc<=alusrc_d;
	aluop<=aluop_d;
	memread<=memread_d;
	pc_src<= pc_src_d;
	pc_src_simulation<=pc_src_d;
	refetch_simulation<=refetch_d;
	memread_simulation<=memread_d;
	opcode_simulation<=opcode;
	ex_memread_simulation2<=ex_memread;
	end if;
end process;	


end Behavioral