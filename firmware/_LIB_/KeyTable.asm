; KEYTABLE_ALPHA
	; DEFB #42	;B
	; DEFB #48	;H
	; DEFB #59	;Y
	; DEFB #36	;6
	; DEFB #35	;5
	; DEFB #54	;T
	; DEFB #47	;G
	; DEFB #56	;V
	; DEFB #4E	;N
	; DEFB #4A	;J
	; DEFB #55	;U
	; DEFB #37	;7
	; DEFB #34	;4
	; DEFB #52	;R
	; DEFB #46	;F
	; DEFB #43	;C
	; DEFB #4D	;M
	; DEFB #4B	;K
	; DEFB #49	;I
	; DEFB #38	;8
	; DEFB #33	;3
	; DEFB #45	;E
	; DEFB #44	;D
	; DEFB #58	;X
	; DEFB #0E	;SYMBOL SHIFT
	; DEFB #4C	;L
	; DEFB #4F	;O
	; DEFB #39	;9
	; DEFB #32	;2
	; DEFB #57	;W
	; DEFB #53	;S
	; DEFB #5A	;Z
	; DEFB #20	;SPACE
	; DEFB #0D	;ENTER
	; DEFB #50	;P
	; DEFB #30	;0
	; DEFB #31	;1
	; DEFB #51	;Q
	; DEFB #41	;A
	

KEYTABLE_ALPHA
	; ROW Right Bottom 0		= B,N,M,SS,Space
	DEFB #20	;SPACE
	DEFB #0E	;SYMBOL SHIFT
	DEFB #4D	;M
	DEFB #4E	;N
	DEFB #42	;B

	; ROW Right Bottom 1 		= H,J,K,L,Enter
	DEFB #0D	;ENTER
	DEFB #4C	;L
	DEFB #4B	;K
	DEFB #4A	;J
	DEFB #48	;H

	; ROW Right Bottom 2		= Y,U,I,O,P
	DEFB #50	;P
	DEFB #4F	;O
	DEFB #49	;I
	DEFB #55	;U
	DEFB #59	;Y

	; ROW Right Top				= 6,7,8,9,0
	DEFB #30	;0
	DEFB #39	;9
	DEFB #38	;8
	DEFB #37	;7
	DEFB #36	;6

	; ROW Left Top				= 5,4,3,2,1
	DEFB #31	;1
	DEFB #32	;2
	DEFB #33	;3
	DEFB #34	;4
	DEFB #35	;5

	; ROW Left Bottom 2	 		= T,R,E,W,Q
	DEFB #51	;Q
	DEFB #57	;W
	DEFB #45	;E
	DEFB #52	;R
	DEFB #54	;T

	; ROW Left Bottom 1	 		= G,F,D,S,A
	DEFB #41	;A
	DEFB #53	;S
	DEFB #44	;D
	DEFB #46	;F
	DEFB #47	;G
	
	; ROW Left Bottom 1	 		= V,C,X,Z,Caps-Shift

	DEFB #0F	;Caps-Shift
	DEFB #5A	;Z
	DEFB #58	;X
	DEFB #43	;C
	DEFB #56	;V
