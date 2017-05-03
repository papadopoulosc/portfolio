---------------------------------------------------------------------------------
--
--  Filename:	BinIO_Pkg.vhd
--  Purpose:	Package for reading and writing binary files
--  Authors:	Huib Lincklaen Arriens, Alexander de Graaf 
--	Date:		May, 2006
--	Modifications:	
--              May, 2007:  to uppercase (Huib)
--  Remarks:	VHDL93, tested with ModelSim
--
--  defines filetypes  binFile_Typ, byteFile_Typ and byteArray_Typ.
--  new procedures:
--		readByteFromFile and writeByteToFile (obvious),
--		readWordFromFile_LE and writeWordToFile_LE, which access words made up 
--			of a number of user definable bytes with the least significant byte 
--			first (little endian),
--		readWordFromFile_BE and writeWordToFile_BE, which access words made up 
--			of a number of user definable bytes with the most significant byte 
--			first (big endian),
--		fread and fwrite, which are more memory oriented and which can read or 
--			write a whole contiguous memory block at once (by specifying to 
--			read or write zero bytes).
--
---------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;


---------------------------------------------------------------------------------
PACKAGE BinIO_Pkg IS
---------------------------------------------------------------------------------
 
	TYPE   binFile_Typ IS FILE OF BIT_VECTOR;
	TYPE  byteFile_Typ IS FILE OF CHARACTER;
	TYPE byteArray_Typ IS ARRAY (INTEGER RANGE <>) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
 

	PROCEDURE readByteFromFile ( FILE fileId_f   :     binFile_Typ; 
								 VARIABLE byte_v : OUT STD_LOGIC_VECTOR );

--  Alternative syntax:
--
--	FUNCTION readByteFromFile ( FILE fileId_f : binFile_Typ ) 
--													RETURN STD_LOGIC_VECTOR;

 	PROCEDURE writeByteToFile  ( FILE fileId_f   :     byteFile_Typ; 
								 VARIABLE byte_v :  IN STD_LOGIC_VECTOR );

	PROCEDURE readWordFromFile_LE ( FILE fileId_f       :     binFile_Typ; 
									VARIABLE word_v     : OUT STD_LOGIC_VECTOR;
									CONSTANT numBytes_c :  IN NATURAL );

	PROCEDURE readWordFromFile_BE ( FILE fileId_f       :     binFile_Typ; 
									VARIABLE word_v     : OUT STD_LOGIC_VECTOR;
									CONSTANT numBytes_c :  IN NATURAL );

	PROCEDURE writeWordToFile_LE  ( FILE fileId_f       :     byteFile_Typ; 
									VARIABLE word_v     :  IN STD_LOGIC_VECTOR;
									CONSTANT numBytes_c :  IN NATURAL );

	PROCEDURE writeWordToFile_BE  ( FILE fileId_f       :     byteFile_Typ; 
									VARIABLE word_v     :  IN STD_LOGIC_VECTOR;
									CONSTANT numBytes_c :  IN NATURAL );
	

	PROCEDURE fread  ( FILE fileId_f        :     binFile_Typ;
                       VARIABLE byteArray_v : OUT byteArray_Typ;
                       CONSTANT numBytes_c  :  IN NATURAL );

	PROCEDURE fwrite ( FILE fileId_f        :     byteFile_Typ;
                       VARIABLE byteArray_v :  IN byteArray_Typ;
                       CONSTANT numBytes_c  :  IN NATURAL );
	
END PACKAGE BinIO_Pkg;
	
	
---------------------------------------------------------------------------------
	PACKAGE BODY BinIO_Pkg IS
---------------------------------------------------------------------------------
	
	PROCEDURE readByteFromFile ( FILE fileId_f   :     binFile_Typ;
								 VARIABLE byte_v : OUT STD_LOGIC_VECTOR ) IS
		VARIABLE bits_v       : BIT_VECTOR (0 DOWNTO 0);
		VARIABLE actual_len_v : NATURAL;
	BEGIN
		IF NOT ENDFILE (fileId_f) THEN
			READ (fileId_f, bits_v, actual_len_v);
		ELSE
			ASSERT FALSE
				REPORT "readByteFromFile: Trying to read past end of file ..." 
				SEVERITY FAILURE;
		END IF;
		IF (actual_len_v > 8) THEN
			ASSERT FALSE
				REPORT "readByteFromFile: Not file of bytes ..." 
				SEVERITY FAILURE;
		ELSE
			byte_v := CONV_STD_LOGIC_VECTOR (BIT'POS(bits_v(0)),8);
		END IF;
	END readByteFromFile;
	
--  Alternative syntax:
--
--	FUNCTION readByteFromFile ( FILE fileId_f : binFile_Typ ) 
--	 												RESULT STD_LOGIC_VECTOR IS 
--		VARIABLE byte_v  : BIT_VECTOR (0 DOWNTO 0);
--		VARIABLE actual_len_v : NATURAL;
--	BEGIN
--		ASSERT NOT ENDFILE (fileId_f)
--			REPORT "(Premature?) EndOfInputFile reached ..." SEVERITY FAILURE;
--	 		READ (fileId_f, byte_v, actual_len_v);
--		ASSERT NOT (actual_len_v > 8) 
--			REPORT "readByteFromFile: Not file of bytes ..." SEVERITY FAILURE;
--		RETURN CONV_STD_LOGIC_VECTOR (BIT'POS(byte_v(0)),8);
--	END readByteFromFile;
	

	----------------------------------------------------------------------------
	
	PROCEDURE writeByteToFile ( FILE fileId_f   :     byteFile_Typ; 
								VARIABLE byte_v :  IN STD_LOGIC_VECTOR ) IS
	BEGIN
		WRITE (fileId_f, CHARACTER'VAL(CONV_INTEGER(UNSIGNED(byte_v))));
	END writeByteToFile;
	
	----------------------------------------------------------------------------
	
	PROCEDURE readWordFromFile_LE ( FILE fileId_f       :     binFile_Typ; 
									VARIABLE word_v     : OUT STD_LOGIC_VECTOR;
									CONSTANT numBytes_c :  IN NATURAL ) IS
	BEGIN
		IF (8*numBytes_c = word_v'LENGTH) THEN
			FOR i IN 0 TO (numBytes_c-1) LOOP
				readByteFromFile (fileId_f, word_v( 8*i+7 DOWNTO 8*i ));
			END LOOP;
		ELSE
			ASSERT FALSE
				REPORT "readWordFromFile_LE: Size and number of bytes don't match ..."
				SEVERITY FAILURE;
		END IF;
	END readWordFromFile_LE;
	
	----------------------------------------------------------------------------
	
	PROCEDURE readWordFromFile_BE ( FILE fileId_f       :     binFile_Typ; 
									VARIABLE word_v     : OUT STD_LOGIC_VECTOR;
									CONSTANT numBytes_c :  IN NATURAL ) IS
	BEGIN
		IF (8*numBytes_c = word_v'LENGTH) THEN
			FOR i IN (numBytes_c-1) DOWNTO 0 LOOP
				readByteFromFile (fileId_f, word_v( 8*i+7 DOWNTO 8*i ));
			END LOOP;
		ELSE
			ASSERT FALSE
				REPORT "readWordFromFile_BE: Size and number of bytes don't match ..."
				SEVERITY FAILURE;
		END IF;
	END readWordFromFile_BE;
	
	----------------------------------------------------------------------------
	
	PROCEDURE writeWordToFile_LE ( FILE fileId_f       :     byteFile_Typ; 
								   VARIABLE word_v     :  IN STD_LOGIC_VECTOR;
								   CONSTANT numBytes_c :  IN NATURAL ) IS
	BEGIN
		IF (8*numBytes_c = word_v'LENGTH) THEN
			FOR i IN 0 TO (numBytes_c-1) LOOP
				writeByteToFile (fileId_f, word_v( 8*i+7 DOWNTO 8*i));
			END LOOP;
		ELSE
			ASSERT FALSE
				REPORT "writeWordToFile_LE: Size and number of bytes don't match ..."
				SEVERITY FAILURE;
		END IF;
	END writeWordToFile_LE;
	
	----------------------------------------------------------------------------
	
	PROCEDURE writeWordToFile_BE ( FILE fileId_f       :     byteFile_Typ; 
								   VARIABLE word_v     :  IN STD_LOGIC_VECTOR;
								   CONSTANT numBytes_c :  IN NATURAL ) IS
	BEGIN
		IF (8*numBytes_c = word_v'LENGTH) THEN
			FOR i IN (numBytes_c-1) DOWNTO 0 LOOP
				writeByteToFile (fileId_f, word_v( 8*i+7 DOWNTO 8*i ));
			END LOOP;
		ELSE
			ASSERT FALSE
				REPORT "writeWordToFile_BE: Size and number of bytes don't match ..."
				SEVERITY FAILURE;
		END IF;
	END writeWordToFile_BE;
	
	--==========================================================================
	
	PROCEDURE fread ( FILE fileId_f        :     binFile_Typ;
					  VARIABLE byteArray_v : OUT byteArray_Typ;
					  CONSTANT numBytes_c  :  IN NATURAL ) IS
		VARIABLE count_v : NATURAL := 0;
	BEGIN
		IF (numBytes_c > byteArray_v'LENGTH) OR (numBytes_c = 0) THEN
			count_v := byteArray_v'LENGTH;
		ELSE
			count_v := numBytes_c;
		END IF;
		FOR i IN 0 TO (count_v-1) LOOP
			readByteFromFile (fileId_f, byteArray_v(i));
--  For the alternative syntax:
--			byteArray_v(i) <= readByteFromFile (fileId_f);
		END LOOP;
	END PROCEDURE fread;
	
	----------------------------------------------------------------------------
	
	PROCEDURE fwrite ( FILE fileId_f        :     byteFile_Typ;
					   VARIABLE byteArray_v :  IN byteArray_Typ;
					   CONSTANT numBytes_c  :  IN natural ) IS
		VARIABLE count_v : NATURAL := 0;
	BEGIN
		IF (numBytes_c > byteArray_v'LENGTH) OR (numBytes_c = 0) THEN
			count_v := byteArray_v'LENGTH;
		ELSE
			count_v := numBytes_c;
		END IF;
		FOR i IN 0 TO (count_v-1) LOOP
			writeByteToFile (fileId_f, byteArray_v(i));
		END LOOP;
	END PROCEDURE fwrite;
	
END PACKAGE BODY BinIO_Pkg;

