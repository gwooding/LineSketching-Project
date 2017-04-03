
.section .data
.align 1
foreColour:
	.hword 0xFFFF

.align 2
graphicsAddress:
	.int 0

.section .text
.globl SetForeColour
SetForeColour:
	cmp r0,#0x10000
	movhi pc,lr
	moveq pc,lr

	ldr r1,=foreColour
	strh r0,[r1]
	mov pc,lr

.globl SetGraphicsAddress
SetGraphicsAddress:
	ldr r1,=graphicsAddress
	str r0,[r1]
	mov pc,lr
	
.globl DrawPixel
DrawPixel:
	px .req r0
	py .req r1
	
	addr .req r2
	ldr addr,=graphicsAddress
	ldr addr,[addr]
	
	height .req r3
	ldr height,[addr,#4]
	sub height,#1
	cmp py,height
	movhi pc,lr
	.unreq height
	
	width .req r3
	ldr width,[addr,#0]
	sub width,#1
	cmp px,width
	movhi pc,lr
	
	ldr addr,[addr,#32]
	add width,#1
	mla px,py,width,px
	.unreq width
	.unreq py
	add addr, px,lsl #1
	.unreq px

	fore .req r3
	ldr fore,=foreColour
	ldrh fore,[fore]
	
	strh fore,[addr]
	.unreq fore
	.unreq addr
	mov pc,lr

.globl DrawLine2
DrawLine2:
	push {r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}
	x0 .req r9
	x1 .req r10
	y0 .req r11
	y1 .req r12

	multiple .req r13
	count .req r14

	breakerValue .req r15
	multiplicationtemp .req r8

	mov count, #0
	mov multiple, #1

	mov x0,r0
	mov x1,r2
	mov y0,r1
	mov y1,r3

	dx .req r4
	dy .req r5
	sx .req r6
	sy .req r7

	cmp x0,x1
	subgt dx,x0,x1
	movgt sx,#-1
	suble dx,x1,x0
	movle sx,#1
	
	cmp y0,y1
	subgt dy,y0,y1
	movgt sy,#-1
	suble dy,y1,y0
	movle sy,#1

	add x1,sx
	add y1,sy

	cmp dx, dy
	bl copydYdXsYsXToMemory
	.unreq sx
	breakerNum .req r6
	movls breakerNum, dy
	.unreq dy
	breakerDenom .req r5
	movls breakerDenom, dx

	blls resetBreaker
	blls copydYdXsYsXFromMemory
	.unreq breakerDenom
	dy .req r5

	movgt breakerNum, dx

	blgt resetBreaker
	blgt copydYdXsYsXFromMemory
	.unreq breakerNum
	sx .req r6

	pixelLoop2$:
		teq x0,x1
		teqne y0,y1
		popeq {r4,r5,r6,r7,r8,r9,r10,r11,r12,pc}

		mov r0,x0
		mov r1,y0
		bl DrawPixel
		cmp dx, dy
		addeq x0, sx
		addeq y0, sy
		blgt horizontalStretch
		bllt verticalStretch

		add count, #1

		b pixelLoop2$

	.unreq x0
	.unreq x1
	.unreq y0
	.unreq y1
	.unreq dx
	.unreq dy
	.unreq sx
	.unreq sy

.globl resetBreaker
resetBreaker:

	x0 .req r9
	x1 .req r10
	y0 .req r11
	y1 .req r12

	multiple .req r13
	count .req r14

	breakerCount .req r4
	breakerDenom .req r5
	breakerNum .req r6
	breakerResult .req r7
	breakerValue .req r15
	multiplicationtemp .req r8

	mov x0,r0
	mov x1,r2
	mov y0,r1
	mov y1,r3

	mov breakerCount, breakerDenom
	mov breakerResult, #0

	quotientFinder:
		cmp breakerCount, breakerNum
		addls breakerResult, #1
		addls breakerCount, breakerDenom
		bls quotientFinder

	mov breakerValue, breakerResult
	add multiple, #1
	bl copydYdXsYsXFromMemory

.globl verticalStretch
verticalStretch:

	x0 .req r9
	x1 .req r10
	y0 .req r11
	y1 .req r12

	multiple .req r13
	count .req r14

	breakerValue .req r15
	multiplicationtemp .req r8

	dx .req r4
	dy .req r5
	sx .req r6
	sy .req r7

	add x0, sx
	teq count, breakerValue
	addeq y0, sy
	
	moveq multiplicationtemp, dy
	muleq multiplicationtemp, multiple
	bleq copydYdXsYsXToMemory
	.unreq sx
	breakerNum .req r6
	moveq breakerNum, multiplicationtemp
	.unreq dy
	breakerDenom .req r5
	moveq breakerDenom, dx
	bleq resetBreaker

.globl horizontalStretch
horizontalStretch:
	
	dx .req r4
	dy .req r5 
	sx .req r6
	sy .req r7
	x0 .req r9
	x1 .req r10
	y0 .req r11
	y1 .req r12

	multiple .req r13
	count .req r14

	breakerValue .req r15
	multiplicationtemp .req r8

	add x0, sx
	teq count, breakerValue
	addeq y0, sy

	moveq multiplicationtemp, dx
	muleq multiplicationtemp, multiple
	bleq copydYdXsYsXToMemory
	.unreq sx
	breakerNum .req r6
	moveq breakerNum, multiplicationtemp
	bleq resetBreaker

.globl copydYdXsYsXToMemory
copydYdXsYsXToMemory:

	dx .req r4
	dy .req r5 
	sx .req r6
	sy .req r7
	dns .req r8
	ldr dns,=DeltasAndSteps
	str dy,[dns,#0]
	str dx,[dns,#4]
	str sy,[dns,#8]
	str sx,[dns,#12]

.globl copydYdXsYsXFromMemory
copydYdXsYsXFromMemory:

	dx .req r4
	dy .req r5 
	sx .req r6
	sy .req r7
	dns .req r8
	ldr dns,=DeltasAndSteps
	ldr dy,[dns,#0]
	ldr dx,[dns,#4]
	ldr sy,[dns,#8]
	ldr sx,[dns,#12]