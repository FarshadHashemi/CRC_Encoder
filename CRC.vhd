Library IEEE ;
Use IEEE.STD_Logic_1164.All ;

Entity CRC Is
	
	Generic(
		Polynomial	:	STD_Logic_Vector(32 Downto 0)	:=	"000000000000000000000000111010101" ;
		CRC_N			:	Integer 								:=	8		
	) ;
	
	Port( 
		Clock					:	In		STD_Logic ;
		Clock_Enable		:	In		STD_Logic ;
		Synchronous_Reset	:	In		STD_Logic ;
		Input_Data			:	In		STD_Logic ;
		Valid_Input_Data	:	In		STD_Logic ;
		Output_Data			:	Out	STD_Logic_Vector(CRC_N-1 Downto 0) ;
		Valid_Output_Data	:	Out	STD_Logic
	) ;
	
End CRC;

Architecture Behavioral Of CRC Is
	
	Signal	Clock_Enable_Register			:	STD_Logic									:= '0' ;
	Signal	Synchronous_Reset_Register		:	STD_Logic									:= '0' ;
	Signal	Input_Data_Register				:	STD_Logic									:= '0' ;
	Signal	Valid_Input_Data_Register		:	STD_Logic									:= '0' ;
--	Valid_Input_Data_Register_1_Clock_Delay
	Signal	Valid_Input_Data_Register_1CD	:	STD_Logic									:= '0' ;
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	Signal	Output_Data_Register				:	STD_Logic_Vector(CRC_N-1 Downto 0) 	:=	(Others=>'0') ;
	Signal	Valid_Output_Data_Register		:	STD_Logic									:= '0' ;

	Constant	Generator							:	STD_Logic_Vector(CRC_N-1 Downto 0)	:= Polynomial(CRC_N-1 Downto 0) ;
	
	Signal	CRC_Code								:	STD_LOGIC_VECTOR(CRC_N-1 Downto 0)	:= (Others=>'0') ;
	
Begin
	
	Process(Clock)
	Begin
		
		If Rising_Edge(Clock) Then
			
		--	Registering Input Ports	
			Input_Data_Register			<=	Input_Data ;
			Valid_Input_Data_Register	<=	Valid_Input_Data ;
			Clock_Enable_Register		<=	Clock_Enable ; 
			Synchronous_Reset_Register	<= Synchronous_Reset ;
		-- %%%%%%%%%%%%%%%%%%%%%%%	
			
		--	Reset
			If (Synchronous_Reset_Register='1') Then
			
				Valid_Input_Data_Register_1CD	<=	'0' ;
				CRC_Code								<=	(Others=>'0') ;
				Output_Data_Register				<= (Others=>'0') ;
				Valid_Output_Data_Register		<=	'0' ;
		-- %%%%%
		
			Elsif (Clock_Enable_Register='1') Then	
				
				Valid_Input_Data_Register_1CD	<=	Valid_Input_Data_Register ;
				
			--	Calculate CRC Code 
				CRC_Code(0)							<=	(CRC_Code(CRC_N-1) XOR Input_Data_Register) AND Generator(0) AND Valid_Input_Data_Register ;
				For i In 1 To CRC_N-1 Loop
					CRC_Code(i)						<=	(((CRC_Code(CRC_N-1) XOR Input_Data_Register) AND Generator(i)) XOR CRC_Code(i-1)) AND Valid_Input_Data_Register  ;
				End Loop ;
			-- %%%%%%%%%%%%%%%%%%
			
			-- Save Resulte And Send It
				Output_Data_Register				<= (Others=>'0') ;
				Valid_Output_Data_Register		<= '0' ;
				If Valid_Input_Data_Register='0' AND Valid_Input_Data_Register_1CD='1' Then
				Output_Data_Register				<= CRC_Code ;
				Valid_Output_Data_Register		<= '1' ;
				End If ;
			-- &&&&&&&&&&&&&&&&&&&&&&&&
			
			End If ;
			
		End If ;
		
	End Process ;
	
--	Registering Output Ports
	Output_Data			<=	Output_Data_Register ;
	Valid_Output_Data	<=	Valid_Output_Data_Register ;
-- %%%%%%%%%%%%%%%%%%%%%%%%	
	
End Behavioral ;
