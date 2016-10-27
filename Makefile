#####Variables######

# Compilador
AVRCC = avr-gcc
AVRCXX = avr-g++

#Opciones de compilación
#Modifica las opciones en base a tus necesidades. Investiga lo que necesitas
AVRFLAGS = -std=gnu99 -o target.hex

#Opciones de subida
#Averigua las opciones de el arduino que estás usando y cámbialo de acuerdo a tus necesidades

mcu = atmega8
f_cpu = 16000000
format = ihex
rate = 19200
port = /dev/ttyusb0
programmer = stk500
target_file = target.hex

#Llamada -> make arduino
#Cada línea dentro de la llamada, con la respectiva identación, se ejecuta en el shell de linux como una instrucción. Con '@' la instrucción no se muestra en el shell, sólo se ejecuta.

arduino:
	#Se concatenan las variables con el archivo a compilar
	# $(AVRCC) o $(AVRCXX) y el archivo *.c o *.cpp o *.ino
	$(AVRCC) $(AVRFLAGS) archivo
	
	#Se concatena para subir el compilado al arduino
	avrdude -F -p $mcu -P $port -c $programmer -b $rate -U flash:w:$target_file
