; Pre-Define ##############################################################

; Functions

RY_FIND                     equ     1
RY_FIND_NEXT                equ     2
RY_OPEN                     equ     3
RY_CLOSE                    equ     4
RY_READ                     equ     5
RY_WRITE                    equ     6
RY_RANDOM                   equ     7
RY_SEED                     equ     8
RY_WRITE_USERID             equ     9
RY_READ_USERID              equ     10
RY_SET_MOUDLE               equ     11
RY_CHECK_MOUDLE             equ     12
RY_WRITE_ARITHMETIC         equ     13
RY_CALCULATE1               equ     14
RY_CALCULATE2               equ     15
RY_CALCULATE3               equ     16
RY_DECREASE                 equ     17

; Error Code

ERR_SUCCESS	equ		0		
ERR_NO_ROCKEY	equ		3		
ERR_INVALID_PASSWORD	equ	4		
ERR_INVALID_PASSWORD_OR_ID equ	5
ERR_SETID		equ	6            
ERR_INVALID_ADDR_OR_SIZE	equ 7	
ERR_UNKNOWN_COMMAND      equ  	8	
ERR_NOTBELEVEL3	equ	9	
ERR_READ		equ	10	
ERR_WRITE          equ        	11	
ERR_RANDOM         equ        	12	
ERR_SEED          equ         	13	
ERR_CALCULATE      equ        	14		
ERR_NO_OPEN		equ	15		
ERR_OPEN_OVERFLOW equ         	16		
ERR_NOMORE		equ	17	
ERR_NEED_FIND		equ	18	
ERR_DECREASE		equ	19	
ERR_AR_BADCOMMAND	equ	20	
ERR_AR_UNKNOWN_OPCODE	equ	21	
ERR_AR_WRONGBEGIN	equ	22	
ERR_AR_WRONG_END	equ	23
ERR_AR_VALUEOVERFLOW	equ	24
ERR_TOOMUCHTHREAD	equ	25 
ERR_RECEIVE_NULL	equ	0x100	
ERR_UNKNOWN_SYSTEM     equ        0x102	
ERR_UNKNOWN		equ	0xffff	

; Function Define #########################################################
