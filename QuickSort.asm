.data
	filenamein: .asciiz "input_sort.txt" # ascii la ma ascii con asciiz la ma unicode
	filenameout: .asciiz "output_sort.txt"
	filein: .space 12000
	fileout: .space 12000
	stringInt: .space 20 #Hình như sao không biêt khi đặt cái này dưới arr thì stringInt này trỏ tới arr[1], hai thằng cùng chung địa chỉ với nhau
	arr: .word 1000
	
	
.text
.globl main
# $s7 dung de luu so ki tu o dong 2, dong chua cac phan tu mang
# $s6 luu so luong phan tu mang
# 


#Hàm main
main:

	addi $s7, $0, 0
	jal ReadFile
	jal FileToArr
#QuickSort
	la $a0, arr      # arr[]
	li $a1, 0	 # low
	sub $a2, $s6, 1  # high
	jal QuickSort
	
	jal ArrToFile
	
	jal WriteFile

	li $v0, 10
	syscall

########################### Read file into buffer filein ####################################################################

ReadFile:
	#open file
	li $v0, 13               #open file with code = 13
	la $a0, filenamein       #save address file name in in register $a0
	li $a1, 0                #flag to read (0), if write is 1
	li  $a2, 0
	syscall
	move $s0, $v0            #luu gia tri tra ve cua $v0

	#Doc file vua moi mo
	li $v0, 14              #Ma doc file la 14
	move $a0, $s0		#Gan $a0 = descripter cua file moi mo o tren
	la $a1, filein		#the buffer that holds the string of the whole file
	li $a2, 100		#luu lai chieu dai cua filein
	syscall
	

	#Nho dong file lai
	li $v0, 16			#close file with code = 16
	move $a0, $s0			#file descriptor to close
	syscall

	jr $ra
########################### Chuyen buffer filein qua mang, mang nay cung la mot buffer.#####################################################################################

FileToArr:
	#Su dung $s1 de luu so luong phan tu cua mang
	la $s0, arr #Su dung $s0 de luu dia chi cua arr, va $s1 de luu so luong phan tu cua mang
	la $s2, filein

#Tinh so chu so cua so so luong phan tu va luu no trong $s3
	getNumDigits:
		move $s3, $0   # $s3 la bien dem so luong chu so cua so phan tu. VD 345 thi co 3 chua so
		move $t0, $s2  # Bien tam t0 giua dia chi cua buffer arr
		whilenumdig:		
			addi $s3, $s3, 1  # Cho so luong so toi thieu cua mang la 1
			addi $t0, $t0, 1
			lb $t1, ($t0)
			bne $t1, 13, whilenumdig #O day la 13 chu khong phai la 10 (10: \n, 13 la \r) vi windown la su ket hop cua \r\n ma \r dung truoc nen no chay mot vong lap nua, con trong linux thi khong no chi la \n
	move $t8, $s3 #Sao chep so luong phan tu trong mang
	move $s1, $0  # Khoi tao s1=0 la so luong phan tu trong mang
	move $t9, $s2 # Lay dia chi cua buffer filein chua noi dung mang
#Tinh so luong phan tu mang
	getNumsArr:		#Lay so luong phsn tu trong mang
		move $t6, $t8   #Lay so luong chu so con lai chua xu ly
		lb $t0, ($t9)     #Load 1 byte tu $s2 sang $t0
		sub $t0, $t0, 48  # Tru di 48 vi cac chu so trong ASCII bat dau la 48->57 muon lay gia tri cua so do phai tru di 48
		beq $t8, 1, aa1
		whilenumvalue:
			addi $t7, $0, 10
			mul $t0, $t0, $t7
			sub $t6, $t6, 1
			bgt  $t6, 1, whilenumvalue
		aa1:
		add $s1, $s1, $t0 #Cong tung byte cua lay ra trong $s2 lai duoc 
		addi $t9,$t9, 1   #Tang dia chi $s2 tuc filein len 1
		lb $t1, ($t9)            #Lay ra mot byte de kiem tra toi ki tu xuong dong chua
		sub $t8, $t8, 1 #Sau moi vong lap thi tru di 1, loai 1 chu so da xu ly
		bgt $t8, 0, getNumsArr  #So sanh so chu so con lai voi 0
#Luu so luong phan tu mang vao doi so $s6
addi $a0, $s1, 0 #Cho nay do lo lam nen khong sua lai so toang
addi $s6, $s1, 0
######################
#Du vao ki thuat o tren ta apdung cho lay phan tu mang
#Lay cac phan tu trong buffer filein dua vao buffer arr
addi $t5, $0, 0
	#lb $t3, ($t9)	########################################3
	addi $t9, $t9, 2	
	move $s2, $t9  #Thay doi lai de bat dau mot chuong moi

	getElements:		#lay tung phan tu trong mang
#Tinh so chu so cua so so luong phan tu va luu no trong $s3
		getNumDigits2:
			move $s3, $0   # $s3 la bien dem so luong chu so cua 1 phan tu. VD 345 thi co 3 chua so
			move $t0, $s2  # Bien tam t0 giua dia chi cua buffer arr
			whilenumdig2:	
				addi $s7, $s7, 1   #Dem so luong ki tu o dong 2	
				addi $s3, $s3, 1  # Cho so luong so toi thieu cua mang la 1
				addi $t0, $t0, 1
				lb $t1, ($t0)
				beq $t1, 13, bb1
				beq $t1, 0, bb1   # Kiem tra ket thuc day phan tu. O day la khong vi khong co ki tu ki thuc chuoi hay xuong dong de bao hieu nen byte tiep theo co gia tri la 0
				bne $t1, 32, whilenumdig2 #O day la 13 chu khong phai la 10 (10: \n, 13 la \r) vi windown la su ket hop cua \r\n ma \r dung truoc nen no chay mot vong lap nua, con trong linux thi khong no chi la \n
		bb1:	
		addi $s7, $s7, 1 #Dem them 1 dau cach nua		
		move $t8, $s3 #
		move $s1, $0  # 
		move $t9, $s2 # 
#Tinh so gia tri cua phan tu
		getNumsArr2:		#Lay so luong chu so cua mot phan tu
			move $t6, $t8   #Lay so luong chu so con lai chua xu ly
			lb $t0, ($t9)    
			sub $t0, $t0, 48  # Tru di 48 vi cac chu so trong ASCII bat dau la 48->57 muon lay gia tri cua so do phai tru di 48
			beq $t8, 1, aa12
			whilenumvalue2:
				addi $t7, $0, 10
				mul $t0, $t0, $t7
				sub $t6, $t6, 1
				bgt  $t6, 1, whilenumvalue2
			aa12:
			add $s1, $s1, $t0 #Cong tung gia tri cua tung chu so lai voi nhau de duoc gia tri cua phan tu mang
			addi $t9,$t9, 1   
			lb $t1, ($t9)            #Lay ra mot byte de kiem tra toi ki tu xuong dong chua
			sub $t8, $t8, 1 #Sau moi vong lap thi tru di 1, loai 1 chu so da xu ly
			bgt $t8, 0, getNumsArr2

		sw $s1, arr($t5) #Tai day neu sw $s1, ($s0) se bi loi dia chi le canh le word
		addi $t5, $t5, 4
		addi $t9, $t9, 1
		move $s2, $t9
		lb $t2, ($t9)
		bne $t2, $0, getElements
		
	jr $ra

##################### Chuyen mang ra file #####################################################################################33333333
# t0 là s? l??ng ph?n t?
# t1 t2 là gu=ia tri cua mot phan tu mang
# t8 là bi?n ??m ?? in t?ng kí t? ra fileout
# s1 n?m gi? ??a ch? buffer stringInt ch?a nh?ng ch? s? c?a ph?n t? m?ng theo th? t? ng??c
# s3 ??m s? l??ng ch? s? c?a ph?n t?
ArrToFile:
#Doi tung chua so trong phan tu mang thanh char
la $s0, arr #Chu y nhung truuong hợp làm việc với buffer tránh nhưng lỗi không đáng có aliged, những trường hợp lw, sw với label
add $t0, $0, $s6 #lay so luong phan tu cua mang de dem vong lap cho viec xu ly nhung phan tu trong mang arr
addi $t8, $0, 0
#Bat dau vong lap xu ly cho tung phan tu mang
	whileArrtoF:
	lw $t1, ($s0) #Lay gia tri mot phan tu trong mang
	la $s1, stringInt #Lay dia chi cua buffer stringInt de chut nua ghi ki tu chu so len nay
		countNumDigit:
			addi $t2, $t1, 0   #Sao chep gia tri phan tu duoc lay ra trong mang
			addi $s3, $0, 0 #$s3 dem so luong so cua mot mang
#Dem so luong chu so cua phan tu mang
			whilenumdig3:
				div $t2, $t2, 10
				mfhi $t3		# Cu phap lay du tu phep chia o tren, Chu so dua vao nguoc voi gia tri phan tu chút nua ta se ?ao nguoc chúng lai
				sb $t3, ($s1)	        #L?u chu s? vào bufer stringInt			
				addi $s1, $s1, 1		
				addi $s3, $s3, 1  # So luong chu so cua phan tu	
				bne $t2, 0, whilenumdig3
#Dao lai cac chu so va luu no vao buffer fileout	
			addi $t3, $s3, 0 # Lay so luong chu so de dem vong lap. $s3 vua tinh o tren
			whileIntToFout:
				sub $s1, $s1, 1   #Su dung dia chi cua $s1 o whilenumdig3 o tren lun cho tien
				lb $t4, ($s1)
				addi $t4, $t4, 48     # Bien tinh gia tri cua 1 ki tu trong ascii
				sb $t4, fileout($t8)  #lay ki tu cuoi cua tringInt gan lan luot lai tu dau den cuoi cho fileout
				addi $t8, $t8, 1 #là bi?n ??m ?? in t?ng kí t? ra fileout
				sub $t3, $t3, 1  #Bien vong lap dua tren so luong chu so
				bgt $t3, 0, whileIntToFout
# Them dau cach giua cac phan tu
		addi $t4, $0, 32  # Them dau cach vao fileout
		sb $t4, fileout($t8)
		addi $t8, $t8, 1	#là bi?n ??m ?? in t?ng kí t? ra fileout
# Tiep tuc xu ly voi nhung phan tu sau trong mang			
	addi $s0, $s0, 4
	sub $t0, $t0, 1
	bgt $t0, 0, whileArrtoF
	
	sub $s7, $s7, 1 # Tru di mot khoang trang vi du mot khoang trang
	jr $ra


################# Write file ###############################################################################################
WriteFile:
#open file
	li $v0, 13                    #open file syscall code = 13
	la $a0, filenameout           #get the file name
	li $a1, 1                     #file flag = write - 1
	li $a2, 0
	syscall
	move $s1, $v0
#Write file
	li $v0, 15
	move $a0, $s1
	la  $a1, fileout
	add $a2, $0, $s7  #Gioi han co bao nhieu ki tu o dongbao nhieu ki tu duoc xuat ra
	syscall
#Close
	li $v0,16
	move $a0,$s1
	syscall
#Jump
	jr $ra		#Nhay vao lai thu tuc main thuc hien lenh ke tiep duoi no de ket thuc chuong trinh


####################### MySwap: ####################################################################################
MySwap:
	#addi $sp, $sp, -12
	#sw $ra, 8($sp)
	#sw $a1, 4($sp)
	#sw $a2, ($sp)
#nop
	move $t0, $a1
	move $a1, $a2
	move $a2, $t0
	jr $ra
####################### Partition ####################################################################################
Partition:
la $t8, arr
	addi $sp, $sp, -12 #Luu hai doi so tu ham QuickSort va dia chi quay ve
	sw $ra, 8($sp) # Dia chi quay ve
	sw $a1, 4($sp) # low
	sw $a2, ($sp) # high
	addi $t7, $0, 4
	mul $t9, $a2, $t7
	lw $t0, arr($t9) # pivot=arr[high]
	add $v0, $0, $a1 # int left = low; left la gia tri tra ve
	subi $t2, $a2, 1 # int right = high - 1
	
	whilePar:
		whilePar1:
			
			ble $v0, $t2, if1
			j err1 #Neu dieu kien tren sai thoat vong lap
			if1:
			add $t7, $0, 4
			mul $t9, $v0, $t7
			lw $t3, arr($t9)
			blt $t3, $t0, cal
			j err2 #Neu dieu kien tren sai thoat vong lap
			cal:
				addi $v0, $v0, 1 #left++
			j whilePar1
		err1:
		err2:
		whilePar2:
			bge $t2, $v0, if2
			j err3
			if2:
			addi $t7, $0, 4
			mul $t9, $t2, $t7
			lw $t3, arr($t9)
			bgt $t3, $t0, cal2
			j err4
			cal2:
				sub $t2, $t2, 1
			j whilePar2
		err3:
		err4:
		bge $v0, $t2, exitPar
		addi $t7, $0, 4
		mul $t9, $v0, $t7
		lw $a1, arr($t9)
		addi $t7, $0, 4
		mul $t9, $t2, $t7
		lw $a2, arr($t9)
		jal MySwap
# Luu nhung so vua swap tro lai mang
		addi $t7, $0, 4
		mul $t9, $v0, $t7
		sw $a1, arr($t9)
		addi $t7, $0, 4
		mul $t9, $t2, $t7
		sw $a2, arr($t9)
		addi $v0, $v0, 1  #left++
		subi $t2, $t2, 1  #right--
		j whilePar
	exitPar:
# swap(arr[left], arr[right]);
	lw $t4, ($sp) #Lay high
	addi $t7, $0, 4
	mul $t9, $v0, $t7
	lw $a1, arr($t9) 
	addi $t7, $0, 4
	mul $t9, $t4, $t7
	lw $a2, arr($t9)
	jal MySwap
#Luu hai so vua swap
	addi $t7, $0, 4
	mul $t9, $v0, $t7
	sw $a1, arr($t9)
	lw $t4, ($sp) #Lay high
	addi $t7, $0, 4
	mul $t9, $t4, $t7
	sw $a2, arr($t9)
	
	lw $ra, 8($sp)
	lw $a1, 4($sp)
	lw $a2, ($sp)
	addi $sp, $sp, 12	
jr $ra
################# QuickSort ##################################################################3
QuickSort:
	addi $sp, $sp, -16 #Luu 4 loai $ra, $a1, $a2, $v0
	sw $ra, 12($sp) # Dia chi quay ve cua ham
	sw $a1, 8($sp) # low
	sw $a2, 4($sp)  # high
	bge $a1, $a2, exits # Dieu kien dung cua de quy
#Vao ham Partition tim pivot
	lw $a1, 8($sp)
	lw $a2, 4($sp)
	jal Partition
	sw $v0, ($sp)  # Luu vi tri cua pivot vao stack
# Nhan gia tri tra ve $v0 tu ham Partition
# De quy mang ben trai
	lw $v0, ($sp)
	sub $a2, $v0, 1 # high = $v0 - 1, $v0 la pivot
	lw $a1, 8($sp)
	jal QuickSort
# De quy mang ben phai
	lw $v0, ($sp)
	lw $a2, 4($sp)
	addi $a1, $v0, 1 # low = $v0 + 1, $v0 la pivot
	jal QuickSort
# Giam stack
	exits:
		lw $ra, 12($sp)
		lw $a1, 8($sp)
		lw $a2, 4($sp)
		lw $v0, ($sp)
		addi $sp, $sp, 16
jr $ra
