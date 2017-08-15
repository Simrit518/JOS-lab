
obj/kern/kernel：     文件格式 elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 56 00 00 00       	call   f0100094 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 20 19 10 f0       	push   $0xf0101920
f0100050:	e8 78 09 00 00       	call   f01009cd <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 11                	jle    f010006d <test_backtrace+0x2d>
		test_backtrace(x-1);
f010005c:	83 ec 0c             	sub    $0xc,%esp
f010005f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100062:	50                   	push   %eax
f0100063:	e8 d8 ff ff ff       	call   f0100040 <test_backtrace>
f0100068:	83 c4 10             	add    $0x10,%esp
f010006b:	eb 11                	jmp    f010007e <test_backtrace+0x3e>
	else
		mon_backtrace(0, 0, 0);
f010006d:	83 ec 04             	sub    $0x4,%esp
f0100070:	6a 00                	push   $0x0
f0100072:	6a 00                	push   $0x0
f0100074:	6a 00                	push   $0x0
f0100076:	e8 2f 07 00 00       	call   f01007aa <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 3c 19 10 f0       	push   $0xf010193c
f0100087:	e8 41 09 00 00       	call   f01009cd <cprintf>
}
f010008c:	83 c4 10             	add    $0x10,%esp
f010008f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100092:	c9                   	leave  
f0100093:	c3                   	ret    

f0100094 <i386_init>:

void
i386_init(void)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	83 ec 1c             	sub    $0x1c,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010009a:	b8 44 29 11 f0       	mov    $0xf0112944,%eax
f010009f:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 23 11 f0       	push   $0xf0112300
f01000ac:	e8 c5 13 00 00       	call   f0101476 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 d9 04 00 00       	call   f010058f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 57 19 10 f0       	push   $0xf0101957
f01000c3:	e8 05 09 00 00       	call   f01009cd <cprintf>
	
	int x=1,y=3,z=4;
	cprintf("x %d,y %x,z %d\n",x,y,z);
f01000c8:	6a 04                	push   $0x4
f01000ca:	6a 03                	push   $0x3
f01000cc:	6a 01                	push   $0x1
f01000ce:	68 72 19 10 f0       	push   $0xf0101972
f01000d3:	e8 f5 08 00 00       	call   f01009cd <cprintf>
	
	unsigned int i = 0x00646c72;
f01000d8:	c7 45 f4 72 6c 64 00 	movl   $0x646c72,-0xc(%ebp)
	cprintf("H%x Wo%s\n",57616,&i);
f01000df:	83 c4 1c             	add    $0x1c,%esp
f01000e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01000e5:	50                   	push   %eax
f01000e6:	68 10 e1 00 00       	push   $0xe110
f01000eb:	68 82 19 10 f0       	push   $0xf0101982
f01000f0:	e8 d8 08 00 00       	call   f01009cd <cprintf>
	
	cprintf("x=%d y=%d\n",3);
f01000f5:	83 c4 08             	add    $0x8,%esp
f01000f8:	6a 03                	push   $0x3
f01000fa:	68 8c 19 10 f0       	push   $0xf010198c
f01000ff:	e8 c9 08 00 00       	call   f01009cd <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f0100104:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f010010b:	e8 30 ff ff ff       	call   f0100040 <test_backtrace>
f0100110:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100113:	83 ec 0c             	sub    $0xc,%esp
f0100116:	6a 00                	push   $0x0
f0100118:	e8 30 07 00 00       	call   f010084d <monitor>
f010011d:	83 c4 10             	add    $0x10,%esp
f0100120:	eb f1                	jmp    f0100113 <i386_init+0x7f>

f0100122 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100122:	55                   	push   %ebp
f0100123:	89 e5                	mov    %esp,%ebp
f0100125:	56                   	push   %esi
f0100126:	53                   	push   %ebx
f0100127:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010012a:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f0100131:	75 37                	jne    f010016a <_panic+0x48>
		goto dead;
	panicstr = fmt;
f0100133:	89 35 40 29 11 f0    	mov    %esi,0xf0112940

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100139:	fa                   	cli    
f010013a:	fc                   	cld    

	va_start(ap, fmt);
f010013b:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f010013e:	83 ec 04             	sub    $0x4,%esp
f0100141:	ff 75 0c             	pushl  0xc(%ebp)
f0100144:	ff 75 08             	pushl  0x8(%ebp)
f0100147:	68 97 19 10 f0       	push   $0xf0101997
f010014c:	e8 7c 08 00 00       	call   f01009cd <cprintf>
	vcprintf(fmt, ap);
f0100151:	83 c4 08             	add    $0x8,%esp
f0100154:	53                   	push   %ebx
f0100155:	56                   	push   %esi
f0100156:	e8 4c 08 00 00       	call   f01009a7 <vcprintf>
	cprintf("\n");
f010015b:	c7 04 24 d3 19 10 f0 	movl   $0xf01019d3,(%esp)
f0100162:	e8 66 08 00 00       	call   f01009cd <cprintf>
	va_end(ap);
f0100167:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010016a:	83 ec 0c             	sub    $0xc,%esp
f010016d:	6a 00                	push   $0x0
f010016f:	e8 d9 06 00 00       	call   f010084d <monitor>
f0100174:	83 c4 10             	add    $0x10,%esp
f0100177:	eb f1                	jmp    f010016a <_panic+0x48>

f0100179 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100179:	55                   	push   %ebp
f010017a:	89 e5                	mov    %esp,%ebp
f010017c:	53                   	push   %ebx
f010017d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100180:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100183:	ff 75 0c             	pushl  0xc(%ebp)
f0100186:	ff 75 08             	pushl  0x8(%ebp)
f0100189:	68 af 19 10 f0       	push   $0xf01019af
f010018e:	e8 3a 08 00 00       	call   f01009cd <cprintf>
	vcprintf(fmt, ap);
f0100193:	83 c4 08             	add    $0x8,%esp
f0100196:	53                   	push   %ebx
f0100197:	ff 75 10             	pushl  0x10(%ebp)
f010019a:	e8 08 08 00 00       	call   f01009a7 <vcprintf>
	cprintf("\n");
f010019f:	c7 04 24 d3 19 10 f0 	movl   $0xf01019d3,(%esp)
f01001a6:	e8 22 08 00 00       	call   f01009cd <cprintf>
	va_end(ap);
}
f01001ab:	83 c4 10             	add    $0x10,%esp
f01001ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01001b1:	c9                   	leave  
f01001b2:	c3                   	ret    

f01001b3 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001b3:	55                   	push   %ebp
f01001b4:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001b6:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001bb:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001bc:	a8 01                	test   $0x1,%al
f01001be:	74 0b                	je     f01001cb <serial_proc_data+0x18>
f01001c0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001c5:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001c6:	0f b6 c0             	movzbl %al,%eax
f01001c9:	eb 05                	jmp    f01001d0 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01001cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01001d0:	5d                   	pop    %ebp
f01001d1:	c3                   	ret    

f01001d2 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001d2:	55                   	push   %ebp
f01001d3:	89 e5                	mov    %esp,%ebp
f01001d5:	53                   	push   %ebx
f01001d6:	83 ec 04             	sub    $0x4,%esp
f01001d9:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001db:	eb 2b                	jmp    f0100208 <cons_intr+0x36>
		if (c == 0)
f01001dd:	85 c0                	test   %eax,%eax
f01001df:	74 27                	je     f0100208 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01001e1:	8b 0d 24 25 11 f0    	mov    0xf0112524,%ecx
f01001e7:	8d 51 01             	lea    0x1(%ecx),%edx
f01001ea:	89 15 24 25 11 f0    	mov    %edx,0xf0112524
f01001f0:	88 81 20 23 11 f0    	mov    %al,-0xfeedce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001f6:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001fc:	75 0a                	jne    f0100208 <cons_intr+0x36>
			cons.wpos = 0;
f01001fe:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f0100205:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100208:	ff d3                	call   *%ebx
f010020a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010020d:	75 ce                	jne    f01001dd <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010020f:	83 c4 04             	add    $0x4,%esp
f0100212:	5b                   	pop    %ebx
f0100213:	5d                   	pop    %ebp
f0100214:	c3                   	ret    

f0100215 <kbd_proc_data>:
f0100215:	ba 64 00 00 00       	mov    $0x64,%edx
f010021a:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f010021b:	a8 01                	test   $0x1,%al
f010021d:	0f 84 f8 00 00 00    	je     f010031b <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f0100223:	a8 20                	test   $0x20,%al
f0100225:	0f 85 f6 00 00 00    	jne    f0100321 <kbd_proc_data+0x10c>
f010022b:	ba 60 00 00 00       	mov    $0x60,%edx
f0100230:	ec                   	in     (%dx),%al
f0100231:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100233:	3c e0                	cmp    $0xe0,%al
f0100235:	75 0d                	jne    f0100244 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f0100237:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f010023e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100243:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100244:	55                   	push   %ebp
f0100245:	89 e5                	mov    %esp,%ebp
f0100247:	53                   	push   %ebx
f0100248:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010024b:	84 c0                	test   %al,%al
f010024d:	79 36                	jns    f0100285 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010024f:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100255:	89 cb                	mov    %ecx,%ebx
f0100257:	83 e3 40             	and    $0x40,%ebx
f010025a:	83 e0 7f             	and    $0x7f,%eax
f010025d:	85 db                	test   %ebx,%ebx
f010025f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100262:	0f b6 d2             	movzbl %dl,%edx
f0100265:	0f b6 82 20 1b 10 f0 	movzbl -0xfefe4e0(%edx),%eax
f010026c:	83 c8 40             	or     $0x40,%eax
f010026f:	0f b6 c0             	movzbl %al,%eax
f0100272:	f7 d0                	not    %eax
f0100274:	21 c8                	and    %ecx,%eax
f0100276:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f010027b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100280:	e9 a4 00 00 00       	jmp    f0100329 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100285:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f010028b:	f6 c1 40             	test   $0x40,%cl
f010028e:	74 0e                	je     f010029e <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100290:	83 c8 80             	or     $0xffffff80,%eax
f0100293:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100295:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100298:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	}

	shift |= shiftcode[data];
f010029e:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f01002a1:	0f b6 82 20 1b 10 f0 	movzbl -0xfefe4e0(%edx),%eax
f01002a8:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
f01002ae:	0f b6 8a 20 1a 10 f0 	movzbl -0xfefe5e0(%edx),%ecx
f01002b5:	31 c8                	xor    %ecx,%eax
f01002b7:	a3 00 23 11 f0       	mov    %eax,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f01002bc:	89 c1                	mov    %eax,%ecx
f01002be:	83 e1 03             	and    $0x3,%ecx
f01002c1:	8b 0c 8d 00 1a 10 f0 	mov    -0xfefe600(,%ecx,4),%ecx
f01002c8:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002cc:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01002cf:	a8 08                	test   $0x8,%al
f01002d1:	74 1b                	je     f01002ee <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f01002d3:	89 da                	mov    %ebx,%edx
f01002d5:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01002d8:	83 f9 19             	cmp    $0x19,%ecx
f01002db:	77 05                	ja     f01002e2 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f01002dd:	83 eb 20             	sub    $0x20,%ebx
f01002e0:	eb 0c                	jmp    f01002ee <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f01002e2:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002e5:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002e8:	83 fa 19             	cmp    $0x19,%edx
f01002eb:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002ee:	f7 d0                	not    %eax
f01002f0:	a8 06                	test   $0x6,%al
f01002f2:	75 33                	jne    f0100327 <kbd_proc_data+0x112>
f01002f4:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002fa:	75 2b                	jne    f0100327 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01002fc:	83 ec 0c             	sub    $0xc,%esp
f01002ff:	68 c9 19 10 f0       	push   $0xf01019c9
f0100304:	e8 c4 06 00 00       	call   f01009cd <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100309:	ba 92 00 00 00       	mov    $0x92,%edx
f010030e:	b8 03 00 00 00       	mov    $0x3,%eax
f0100313:	ee                   	out    %al,(%dx)
f0100314:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100317:	89 d8                	mov    %ebx,%eax
f0100319:	eb 0e                	jmp    f0100329 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f010031b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100320:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f0100321:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100326:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100327:	89 d8                	mov    %ebx,%eax
}
f0100329:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010032c:	c9                   	leave  
f010032d:	c3                   	ret    

f010032e <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010032e:	55                   	push   %ebp
f010032f:	89 e5                	mov    %esp,%ebp
f0100331:	57                   	push   %edi
f0100332:	56                   	push   %esi
f0100333:	53                   	push   %ebx
f0100334:	83 ec 1c             	sub    $0x1c,%esp
f0100337:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100339:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010033e:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100343:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100348:	eb 09                	jmp    f0100353 <cons_putc+0x25>
f010034a:	89 ca                	mov    %ecx,%edx
f010034c:	ec                   	in     (%dx),%al
f010034d:	ec                   	in     (%dx),%al
f010034e:	ec                   	in     (%dx),%al
f010034f:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100350:	83 c3 01             	add    $0x1,%ebx
f0100353:	89 f2                	mov    %esi,%edx
f0100355:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100356:	a8 20                	test   $0x20,%al
f0100358:	75 08                	jne    f0100362 <cons_putc+0x34>
f010035a:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100360:	7e e8                	jle    f010034a <cons_putc+0x1c>
f0100362:	89 f8                	mov    %edi,%eax
f0100364:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100367:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010036c:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010036d:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100372:	be 79 03 00 00       	mov    $0x379,%esi
f0100377:	b9 84 00 00 00       	mov    $0x84,%ecx
f010037c:	eb 09                	jmp    f0100387 <cons_putc+0x59>
f010037e:	89 ca                	mov    %ecx,%edx
f0100380:	ec                   	in     (%dx),%al
f0100381:	ec                   	in     (%dx),%al
f0100382:	ec                   	in     (%dx),%al
f0100383:	ec                   	in     (%dx),%al
f0100384:	83 c3 01             	add    $0x1,%ebx
f0100387:	89 f2                	mov    %esi,%edx
f0100389:	ec                   	in     (%dx),%al
f010038a:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100390:	7f 04                	jg     f0100396 <cons_putc+0x68>
f0100392:	84 c0                	test   %al,%al
f0100394:	79 e8                	jns    f010037e <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100396:	ba 78 03 00 00       	mov    $0x378,%edx
f010039b:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010039f:	ee                   	out    %al,(%dx)
f01003a0:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003a5:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003aa:	ee                   	out    %al,(%dx)
f01003ab:	b8 08 00 00 00       	mov    $0x8,%eax
f01003b0:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01003b1:	89 fa                	mov    %edi,%edx
f01003b3:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003b9:	89 f8                	mov    %edi,%eax
f01003bb:	80 cc 07             	or     $0x7,%ah
f01003be:	85 d2                	test   %edx,%edx
f01003c0:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01003c3:	89 f8                	mov    %edi,%eax
f01003c5:	0f b6 c0             	movzbl %al,%eax
f01003c8:	83 f8 09             	cmp    $0x9,%eax
f01003cb:	74 74                	je     f0100441 <cons_putc+0x113>
f01003cd:	83 f8 09             	cmp    $0x9,%eax
f01003d0:	7f 0a                	jg     f01003dc <cons_putc+0xae>
f01003d2:	83 f8 08             	cmp    $0x8,%eax
f01003d5:	74 14                	je     f01003eb <cons_putc+0xbd>
f01003d7:	e9 99 00 00 00       	jmp    f0100475 <cons_putc+0x147>
f01003dc:	83 f8 0a             	cmp    $0xa,%eax
f01003df:	74 3a                	je     f010041b <cons_putc+0xed>
f01003e1:	83 f8 0d             	cmp    $0xd,%eax
f01003e4:	74 3d                	je     f0100423 <cons_putc+0xf5>
f01003e6:	e9 8a 00 00 00       	jmp    f0100475 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01003eb:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003f2:	66 85 c0             	test   %ax,%ax
f01003f5:	0f 84 e6 00 00 00    	je     f01004e1 <cons_putc+0x1b3>
			crt_pos--;
f01003fb:	83 e8 01             	sub    $0x1,%eax
f01003fe:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100404:	0f b7 c0             	movzwl %ax,%eax
f0100407:	66 81 e7 00 ff       	and    $0xff00,%di
f010040c:	83 cf 20             	or     $0x20,%edi
f010040f:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100415:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100419:	eb 78                	jmp    f0100493 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010041b:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f0100422:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100423:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f010042a:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100430:	c1 e8 16             	shr    $0x16,%eax
f0100433:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100436:	c1 e0 04             	shl    $0x4,%eax
f0100439:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
f010043f:	eb 52                	jmp    f0100493 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f0100441:	b8 20 00 00 00       	mov    $0x20,%eax
f0100446:	e8 e3 fe ff ff       	call   f010032e <cons_putc>
		cons_putc(' ');
f010044b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100450:	e8 d9 fe ff ff       	call   f010032e <cons_putc>
		cons_putc(' ');
f0100455:	b8 20 00 00 00       	mov    $0x20,%eax
f010045a:	e8 cf fe ff ff       	call   f010032e <cons_putc>
		cons_putc(' ');
f010045f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100464:	e8 c5 fe ff ff       	call   f010032e <cons_putc>
		cons_putc(' ');
f0100469:	b8 20 00 00 00       	mov    $0x20,%eax
f010046e:	e8 bb fe ff ff       	call   f010032e <cons_putc>
f0100473:	eb 1e                	jmp    f0100493 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100475:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f010047c:	8d 50 01             	lea    0x1(%eax),%edx
f010047f:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f0100486:	0f b7 c0             	movzwl %ax,%eax
f0100489:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f010048f:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100493:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f010049a:	cf 07 
f010049c:	76 43                	jbe    f01004e1 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010049e:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f01004a3:	83 ec 04             	sub    $0x4,%esp
f01004a6:	68 00 0f 00 00       	push   $0xf00
f01004ab:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004b1:	52                   	push   %edx
f01004b2:	50                   	push   %eax
f01004b3:	e8 0b 10 00 00       	call   f01014c3 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004b8:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01004be:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01004c4:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01004ca:	83 c4 10             	add    $0x10,%esp
f01004cd:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01004d2:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004d5:	39 d0                	cmp    %edx,%eax
f01004d7:	75 f4                	jne    f01004cd <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004d9:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f01004e0:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004e1:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f01004e7:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004ec:	89 ca                	mov    %ecx,%edx
f01004ee:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004ef:	0f b7 1d 28 25 11 f0 	movzwl 0xf0112528,%ebx
f01004f6:	8d 71 01             	lea    0x1(%ecx),%esi
f01004f9:	89 d8                	mov    %ebx,%eax
f01004fb:	66 c1 e8 08          	shr    $0x8,%ax
f01004ff:	89 f2                	mov    %esi,%edx
f0100501:	ee                   	out    %al,(%dx)
f0100502:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100507:	89 ca                	mov    %ecx,%edx
f0100509:	ee                   	out    %al,(%dx)
f010050a:	89 d8                	mov    %ebx,%eax
f010050c:	89 f2                	mov    %esi,%edx
f010050e:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010050f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100512:	5b                   	pop    %ebx
f0100513:	5e                   	pop    %esi
f0100514:	5f                   	pop    %edi
f0100515:	5d                   	pop    %ebp
f0100516:	c3                   	ret    

f0100517 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100517:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f010051e:	74 11                	je     f0100531 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100520:	55                   	push   %ebp
f0100521:	89 e5                	mov    %esp,%ebp
f0100523:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100526:	b8 b3 01 10 f0       	mov    $0xf01001b3,%eax
f010052b:	e8 a2 fc ff ff       	call   f01001d2 <cons_intr>
}
f0100530:	c9                   	leave  
f0100531:	f3 c3                	repz ret 

f0100533 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100533:	55                   	push   %ebp
f0100534:	89 e5                	mov    %esp,%ebp
f0100536:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100539:	b8 15 02 10 f0       	mov    $0xf0100215,%eax
f010053e:	e8 8f fc ff ff       	call   f01001d2 <cons_intr>
}
f0100543:	c9                   	leave  
f0100544:	c3                   	ret    

f0100545 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100545:	55                   	push   %ebp
f0100546:	89 e5                	mov    %esp,%ebp
f0100548:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010054b:	e8 c7 ff ff ff       	call   f0100517 <serial_intr>
	kbd_intr();
f0100550:	e8 de ff ff ff       	call   f0100533 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100555:	a1 20 25 11 f0       	mov    0xf0112520,%eax
f010055a:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f0100560:	74 26                	je     f0100588 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100562:	8d 50 01             	lea    0x1(%eax),%edx
f0100565:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
f010056b:	0f b6 88 20 23 11 f0 	movzbl -0xfeedce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100572:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100574:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010057a:	75 11                	jne    f010058d <cons_getc+0x48>
			cons.rpos = 0;
f010057c:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f0100583:	00 00 00 
f0100586:	eb 05                	jmp    f010058d <cons_getc+0x48>
		return c;
	}
	return 0;
f0100588:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010058d:	c9                   	leave  
f010058e:	c3                   	ret    

f010058f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010058f:	55                   	push   %ebp
f0100590:	89 e5                	mov    %esp,%ebp
f0100592:	57                   	push   %edi
f0100593:	56                   	push   %esi
f0100594:	53                   	push   %ebx
f0100595:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100598:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010059f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01005a6:	5a a5 
	if (*cp != 0xA55A) {
f01005a8:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01005af:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005b3:	74 11                	je     f01005c6 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01005b5:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f01005bc:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005bf:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01005c4:	eb 16                	jmp    f01005dc <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01005c6:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01005cd:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f01005d4:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01005d7:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005dc:	8b 3d 30 25 11 f0    	mov    0xf0112530,%edi
f01005e2:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005e7:	89 fa                	mov    %edi,%edx
f01005e9:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005ea:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005ed:	89 da                	mov    %ebx,%edx
f01005ef:	ec                   	in     (%dx),%al
f01005f0:	0f b6 c8             	movzbl %al,%ecx
f01005f3:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005f6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005fb:	89 fa                	mov    %edi,%edx
f01005fd:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005fe:	89 da                	mov    %ebx,%edx
f0100600:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100601:	89 35 2c 25 11 f0    	mov    %esi,0xf011252c
	crt_pos = pos;
f0100607:	0f b6 c0             	movzbl %al,%eax
f010060a:	09 c8                	or     %ecx,%eax
f010060c:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100612:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100617:	b8 00 00 00 00       	mov    $0x0,%eax
f010061c:	89 f2                	mov    %esi,%edx
f010061e:	ee                   	out    %al,(%dx)
f010061f:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100624:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100629:	ee                   	out    %al,(%dx)
f010062a:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f010062f:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100634:	89 da                	mov    %ebx,%edx
f0100636:	ee                   	out    %al,(%dx)
f0100637:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010063c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100641:	ee                   	out    %al,(%dx)
f0100642:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100647:	b8 03 00 00 00       	mov    $0x3,%eax
f010064c:	ee                   	out    %al,(%dx)
f010064d:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100652:	b8 00 00 00 00       	mov    $0x0,%eax
f0100657:	ee                   	out    %al,(%dx)
f0100658:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010065d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100662:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100663:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100668:	ec                   	in     (%dx),%al
f0100669:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010066b:	3c ff                	cmp    $0xff,%al
f010066d:	0f 95 05 34 25 11 f0 	setne  0xf0112534
f0100674:	89 f2                	mov    %esi,%edx
f0100676:	ec                   	in     (%dx),%al
f0100677:	89 da                	mov    %ebx,%edx
f0100679:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010067a:	80 f9 ff             	cmp    $0xff,%cl
f010067d:	75 10                	jne    f010068f <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f010067f:	83 ec 0c             	sub    $0xc,%esp
f0100682:	68 d5 19 10 f0       	push   $0xf01019d5
f0100687:	e8 41 03 00 00       	call   f01009cd <cprintf>
f010068c:	83 c4 10             	add    $0x10,%esp
}
f010068f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100692:	5b                   	pop    %ebx
f0100693:	5e                   	pop    %esi
f0100694:	5f                   	pop    %edi
f0100695:	5d                   	pop    %ebp
f0100696:	c3                   	ret    

f0100697 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100697:	55                   	push   %ebp
f0100698:	89 e5                	mov    %esp,%ebp
f010069a:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010069d:	8b 45 08             	mov    0x8(%ebp),%eax
f01006a0:	e8 89 fc ff ff       	call   f010032e <cons_putc>
}
f01006a5:	c9                   	leave  
f01006a6:	c3                   	ret    

f01006a7 <getchar>:

int
getchar(void)
{
f01006a7:	55                   	push   %ebp
f01006a8:	89 e5                	mov    %esp,%ebp
f01006aa:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01006ad:	e8 93 fe ff ff       	call   f0100545 <cons_getc>
f01006b2:	85 c0                	test   %eax,%eax
f01006b4:	74 f7                	je     f01006ad <getchar+0x6>
		/* do nothing */;
	return c;
}
f01006b6:	c9                   	leave  
f01006b7:	c3                   	ret    

f01006b8 <iscons>:

int
iscons(int fdnum)
{
f01006b8:	55                   	push   %ebp
f01006b9:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01006bb:	b8 01 00 00 00       	mov    $0x1,%eax
f01006c0:	5d                   	pop    %ebp
f01006c1:	c3                   	ret    

f01006c2 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006c2:	55                   	push   %ebp
f01006c3:	89 e5                	mov    %esp,%ebp
f01006c5:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006c8:	68 20 1c 10 f0       	push   $0xf0101c20
f01006cd:	68 3e 1c 10 f0       	push   $0xf0101c3e
f01006d2:	68 43 1c 10 f0       	push   $0xf0101c43
f01006d7:	e8 f1 02 00 00       	call   f01009cd <cprintf>
f01006dc:	83 c4 0c             	add    $0xc,%esp
f01006df:	68 ec 1c 10 f0       	push   $0xf0101cec
f01006e4:	68 4c 1c 10 f0       	push   $0xf0101c4c
f01006e9:	68 43 1c 10 f0       	push   $0xf0101c43
f01006ee:	e8 da 02 00 00       	call   f01009cd <cprintf>
	return 0;
}
f01006f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01006f8:	c9                   	leave  
f01006f9:	c3                   	ret    

f01006fa <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006fa:	55                   	push   %ebp
f01006fb:	89 e5                	mov    %esp,%ebp
f01006fd:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100700:	68 55 1c 10 f0       	push   $0xf0101c55
f0100705:	e8 c3 02 00 00       	call   f01009cd <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010070a:	83 c4 08             	add    $0x8,%esp
f010070d:	68 0c 00 10 00       	push   $0x10000c
f0100712:	68 14 1d 10 f0       	push   $0xf0101d14
f0100717:	e8 b1 02 00 00       	call   f01009cd <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010071c:	83 c4 0c             	add    $0xc,%esp
f010071f:	68 0c 00 10 00       	push   $0x10000c
f0100724:	68 0c 00 10 f0       	push   $0xf010000c
f0100729:	68 3c 1d 10 f0       	push   $0xf0101d3c
f010072e:	e8 9a 02 00 00       	call   f01009cd <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100733:	83 c4 0c             	add    $0xc,%esp
f0100736:	68 01 19 10 00       	push   $0x101901
f010073b:	68 01 19 10 f0       	push   $0xf0101901
f0100740:	68 60 1d 10 f0       	push   $0xf0101d60
f0100745:	e8 83 02 00 00       	call   f01009cd <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010074a:	83 c4 0c             	add    $0xc,%esp
f010074d:	68 00 23 11 00       	push   $0x112300
f0100752:	68 00 23 11 f0       	push   $0xf0112300
f0100757:	68 84 1d 10 f0       	push   $0xf0101d84
f010075c:	e8 6c 02 00 00       	call   f01009cd <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100761:	83 c4 0c             	add    $0xc,%esp
f0100764:	68 44 29 11 00       	push   $0x112944
f0100769:	68 44 29 11 f0       	push   $0xf0112944
f010076e:	68 a8 1d 10 f0       	push   $0xf0101da8
f0100773:	e8 55 02 00 00       	call   f01009cd <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100778:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
f010077d:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100782:	83 c4 08             	add    $0x8,%esp
f0100785:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010078a:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100790:	85 c0                	test   %eax,%eax
f0100792:	0f 48 c2             	cmovs  %edx,%eax
f0100795:	c1 f8 0a             	sar    $0xa,%eax
f0100798:	50                   	push   %eax
f0100799:	68 cc 1d 10 f0       	push   $0xf0101dcc
f010079e:	e8 2a 02 00 00       	call   f01009cd <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01007a3:	b8 00 00 00 00       	mov    $0x0,%eax
f01007a8:	c9                   	leave  
f01007a9:	c3                   	ret    

f01007aa <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01007aa:	55                   	push   %ebp
f01007ab:	89 e5                	mov    %esp,%ebp
f01007ad:	57                   	push   %edi
f01007ae:	56                   	push   %esi
f01007af:	53                   	push   %ebx
f01007b0:	83 ec 48             	sub    $0x48,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01007b3:	89 ee                	mov    %ebp,%esi
	// Your code here.
	uint32_t* ebp = (uint32_t*) read_ebp();
  cprintf("Stack backtrace:\n");
f01007b5:	68 6e 1c 10 f0       	push   $0xf0101c6e
f01007ba:	e8 0e 02 00 00       	call   f01009cd <cprintf>
  while (ebp) {
f01007bf:	83 c4 10             	add    $0x10,%esp
f01007c2:	eb 78                	jmp    f010083c <mon_backtrace+0x92>
    uint32_t eip = ebp[1];
f01007c4:	8b 46 04             	mov    0x4(%esi),%eax
f01007c7:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    cprintf("ebp %x  eip %x  args", ebp, eip);
f01007ca:	83 ec 04             	sub    $0x4,%esp
f01007cd:	50                   	push   %eax
f01007ce:	56                   	push   %esi
f01007cf:	68 80 1c 10 f0       	push   $0xf0101c80
f01007d4:	e8 f4 01 00 00       	call   f01009cd <cprintf>
f01007d9:	8d 5e 08             	lea    0x8(%esi),%ebx
f01007dc:	8d 7e 1c             	lea    0x1c(%esi),%edi
f01007df:	83 c4 10             	add    $0x10,%esp
    int i;
    for (i = 2; i <= 6; ++i)
      cprintf(" %08.x", ebp[i]);
f01007e2:	83 ec 08             	sub    $0x8,%esp
f01007e5:	ff 33                	pushl  (%ebx)
f01007e7:	68 95 1c 10 f0       	push   $0xf0101c95
f01007ec:	e8 dc 01 00 00       	call   f01009cd <cprintf>
f01007f1:	83 c3 04             	add    $0x4,%ebx
  cprintf("Stack backtrace:\n");
  while (ebp) {
    uint32_t eip = ebp[1];
    cprintf("ebp %x  eip %x  args", ebp, eip);
    int i;
    for (i = 2; i <= 6; ++i)
f01007f4:	83 c4 10             	add    $0x10,%esp
f01007f7:	39 fb                	cmp    %edi,%ebx
f01007f9:	75 e7                	jne    f01007e2 <mon_backtrace+0x38>
      cprintf(" %08.x", ebp[i]);
    cprintf("\n");
f01007fb:	83 ec 0c             	sub    $0xc,%esp
f01007fe:	68 d3 19 10 f0       	push   $0xf01019d3
f0100803:	e8 c5 01 00 00       	call   f01009cd <cprintf>
    struct Eipdebuginfo info;
    debuginfo_eip(eip, &info);
f0100808:	83 c4 08             	add    $0x8,%esp
f010080b:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010080e:	50                   	push   %eax
f010080f:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100812:	57                   	push   %edi
f0100813:	e8 bf 02 00 00       	call   f0100ad7 <debuginfo_eip>
    cprintf("\t%s:%d: %.*s+%d\n", 
f0100818:	83 c4 08             	add    $0x8,%esp
f010081b:	89 f8                	mov    %edi,%eax
f010081d:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100820:	50                   	push   %eax
f0100821:	ff 75 d8             	pushl  -0x28(%ebp)
f0100824:	ff 75 dc             	pushl  -0x24(%ebp)
f0100827:	ff 75 d4             	pushl  -0x2c(%ebp)
f010082a:	ff 75 d0             	pushl  -0x30(%ebp)
f010082d:	68 9c 1c 10 f0       	push   $0xf0101c9c
f0100832:	e8 96 01 00 00       	call   f01009cd <cprintf>
      info.eip_file, info.eip_line,
      info.eip_fn_namelen, info.eip_fn_name,
      eip-info.eip_fn_addr);
//         kern/monitor.c:143: monitor+106
    ebp = (uint32_t*) *ebp;
f0100837:	8b 36                	mov    (%esi),%esi
f0100839:	83 c4 20             	add    $0x20,%esp
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	uint32_t* ebp = (uint32_t*) read_ebp();
  cprintf("Stack backtrace:\n");
  while (ebp) {
f010083c:	85 f6                	test   %esi,%esi
f010083e:	75 84                	jne    f01007c4 <mon_backtrace+0x1a>
      eip-info.eip_fn_addr);
//         kern/monitor.c:143: monitor+106
    ebp = (uint32_t*) *ebp;
  }
  return 0;
}
f0100840:	b8 00 00 00 00       	mov    $0x0,%eax
f0100845:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100848:	5b                   	pop    %ebx
f0100849:	5e                   	pop    %esi
f010084a:	5f                   	pop    %edi
f010084b:	5d                   	pop    %ebp
f010084c:	c3                   	ret    

f010084d <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010084d:	55                   	push   %ebp
f010084e:	89 e5                	mov    %esp,%ebp
f0100850:	57                   	push   %edi
f0100851:	56                   	push   %esi
f0100852:	53                   	push   %ebx
f0100853:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100856:	68 f8 1d 10 f0       	push   $0xf0101df8
f010085b:	e8 6d 01 00 00       	call   f01009cd <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100860:	c7 04 24 1c 1e 10 f0 	movl   $0xf0101e1c,(%esp)
f0100867:	e8 61 01 00 00       	call   f01009cd <cprintf>
f010086c:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f010086f:	83 ec 0c             	sub    $0xc,%esp
f0100872:	68 ad 1c 10 f0       	push   $0xf0101cad
f0100877:	e8 a3 09 00 00       	call   f010121f <readline>
f010087c:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010087e:	83 c4 10             	add    $0x10,%esp
f0100881:	85 c0                	test   %eax,%eax
f0100883:	74 ea                	je     f010086f <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100885:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010088c:	be 00 00 00 00       	mov    $0x0,%esi
f0100891:	eb 0a                	jmp    f010089d <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100893:	c6 03 00             	movb   $0x0,(%ebx)
f0100896:	89 f7                	mov    %esi,%edi
f0100898:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010089b:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010089d:	0f b6 03             	movzbl (%ebx),%eax
f01008a0:	84 c0                	test   %al,%al
f01008a2:	74 63                	je     f0100907 <monitor+0xba>
f01008a4:	83 ec 08             	sub    $0x8,%esp
f01008a7:	0f be c0             	movsbl %al,%eax
f01008aa:	50                   	push   %eax
f01008ab:	68 b1 1c 10 f0       	push   $0xf0101cb1
f01008b0:	e8 84 0b 00 00       	call   f0101439 <strchr>
f01008b5:	83 c4 10             	add    $0x10,%esp
f01008b8:	85 c0                	test   %eax,%eax
f01008ba:	75 d7                	jne    f0100893 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f01008bc:	80 3b 00             	cmpb   $0x0,(%ebx)
f01008bf:	74 46                	je     f0100907 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01008c1:	83 fe 0f             	cmp    $0xf,%esi
f01008c4:	75 14                	jne    f01008da <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008c6:	83 ec 08             	sub    $0x8,%esp
f01008c9:	6a 10                	push   $0x10
f01008cb:	68 b6 1c 10 f0       	push   $0xf0101cb6
f01008d0:	e8 f8 00 00 00       	call   f01009cd <cprintf>
f01008d5:	83 c4 10             	add    $0x10,%esp
f01008d8:	eb 95                	jmp    f010086f <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f01008da:	8d 7e 01             	lea    0x1(%esi),%edi
f01008dd:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008e1:	eb 03                	jmp    f01008e6 <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01008e3:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008e6:	0f b6 03             	movzbl (%ebx),%eax
f01008e9:	84 c0                	test   %al,%al
f01008eb:	74 ae                	je     f010089b <monitor+0x4e>
f01008ed:	83 ec 08             	sub    $0x8,%esp
f01008f0:	0f be c0             	movsbl %al,%eax
f01008f3:	50                   	push   %eax
f01008f4:	68 b1 1c 10 f0       	push   $0xf0101cb1
f01008f9:	e8 3b 0b 00 00       	call   f0101439 <strchr>
f01008fe:	83 c4 10             	add    $0x10,%esp
f0100901:	85 c0                	test   %eax,%eax
f0100903:	74 de                	je     f01008e3 <monitor+0x96>
f0100905:	eb 94                	jmp    f010089b <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f0100907:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f010090e:	00 

	// Lookup and invoke the command
	if (argc == 0)
f010090f:	85 f6                	test   %esi,%esi
f0100911:	0f 84 58 ff ff ff    	je     f010086f <monitor+0x22>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100917:	83 ec 08             	sub    $0x8,%esp
f010091a:	68 3e 1c 10 f0       	push   $0xf0101c3e
f010091f:	ff 75 a8             	pushl  -0x58(%ebp)
f0100922:	e8 b4 0a 00 00       	call   f01013db <strcmp>
f0100927:	83 c4 10             	add    $0x10,%esp
f010092a:	85 c0                	test   %eax,%eax
f010092c:	74 1e                	je     f010094c <monitor+0xff>
f010092e:	83 ec 08             	sub    $0x8,%esp
f0100931:	68 4c 1c 10 f0       	push   $0xf0101c4c
f0100936:	ff 75 a8             	pushl  -0x58(%ebp)
f0100939:	e8 9d 0a 00 00       	call   f01013db <strcmp>
f010093e:	83 c4 10             	add    $0x10,%esp
f0100941:	85 c0                	test   %eax,%eax
f0100943:	75 2f                	jne    f0100974 <monitor+0x127>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100945:	b8 01 00 00 00       	mov    $0x1,%eax
f010094a:	eb 05                	jmp    f0100951 <monitor+0x104>
		if (strcmp(argv[0], commands[i].name) == 0)
f010094c:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f0100951:	83 ec 04             	sub    $0x4,%esp
f0100954:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100957:	01 d0                	add    %edx,%eax
f0100959:	ff 75 08             	pushl  0x8(%ebp)
f010095c:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f010095f:	51                   	push   %ecx
f0100960:	56                   	push   %esi
f0100961:	ff 14 85 4c 1e 10 f0 	call   *-0xfefe1b4(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100968:	83 c4 10             	add    $0x10,%esp
f010096b:	85 c0                	test   %eax,%eax
f010096d:	78 1d                	js     f010098c <monitor+0x13f>
f010096f:	e9 fb fe ff ff       	jmp    f010086f <monitor+0x22>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100974:	83 ec 08             	sub    $0x8,%esp
f0100977:	ff 75 a8             	pushl  -0x58(%ebp)
f010097a:	68 d3 1c 10 f0       	push   $0xf0101cd3
f010097f:	e8 49 00 00 00       	call   f01009cd <cprintf>
f0100984:	83 c4 10             	add    $0x10,%esp
f0100987:	e9 e3 fe ff ff       	jmp    f010086f <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010098c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010098f:	5b                   	pop    %ebx
f0100990:	5e                   	pop    %esi
f0100991:	5f                   	pop    %edi
f0100992:	5d                   	pop    %ebp
f0100993:	c3                   	ret    

f0100994 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100994:	55                   	push   %ebp
f0100995:	89 e5                	mov    %esp,%ebp
f0100997:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010099a:	ff 75 08             	pushl  0x8(%ebp)
f010099d:	e8 f5 fc ff ff       	call   f0100697 <cputchar>
	*cnt++;
}
f01009a2:	83 c4 10             	add    $0x10,%esp
f01009a5:	c9                   	leave  
f01009a6:	c3                   	ret    

f01009a7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01009a7:	55                   	push   %ebp
f01009a8:	89 e5                	mov    %esp,%ebp
f01009aa:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01009ad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01009b4:	ff 75 0c             	pushl  0xc(%ebp)
f01009b7:	ff 75 08             	pushl  0x8(%ebp)
f01009ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01009bd:	50                   	push   %eax
f01009be:	68 94 09 10 f0       	push   $0xf0100994
f01009c3:	e8 42 04 00 00       	call   f0100e0a <vprintfmt>
	return cnt;
}
f01009c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01009cb:	c9                   	leave  
f01009cc:	c3                   	ret    

f01009cd <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01009cd:	55                   	push   %ebp
f01009ce:	89 e5                	mov    %esp,%ebp
f01009d0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01009d3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01009d6:	50                   	push   %eax
f01009d7:	ff 75 08             	pushl  0x8(%ebp)
f01009da:	e8 c8 ff ff ff       	call   f01009a7 <vcprintf>
	va_end(ap);

	return cnt;
}
f01009df:	c9                   	leave  
f01009e0:	c3                   	ret    

f01009e1 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01009e1:	55                   	push   %ebp
f01009e2:	89 e5                	mov    %esp,%ebp
f01009e4:	57                   	push   %edi
f01009e5:	56                   	push   %esi
f01009e6:	53                   	push   %ebx
f01009e7:	83 ec 14             	sub    $0x14,%esp
f01009ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01009ed:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01009f0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01009f3:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01009f6:	8b 1a                	mov    (%edx),%ebx
f01009f8:	8b 01                	mov    (%ecx),%eax
f01009fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01009fd:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100a04:	eb 7f                	jmp    f0100a85 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0100a06:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100a09:	01 d8                	add    %ebx,%eax
f0100a0b:	89 c6                	mov    %eax,%esi
f0100a0d:	c1 ee 1f             	shr    $0x1f,%esi
f0100a10:	01 c6                	add    %eax,%esi
f0100a12:	d1 fe                	sar    %esi
f0100a14:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100a17:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100a1a:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0100a1d:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a1f:	eb 03                	jmp    f0100a24 <stab_binsearch+0x43>
			m--;
f0100a21:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a24:	39 c3                	cmp    %eax,%ebx
f0100a26:	7f 0d                	jg     f0100a35 <stab_binsearch+0x54>
f0100a28:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100a2c:	83 ea 0c             	sub    $0xc,%edx
f0100a2f:	39 f9                	cmp    %edi,%ecx
f0100a31:	75 ee                	jne    f0100a21 <stab_binsearch+0x40>
f0100a33:	eb 05                	jmp    f0100a3a <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100a35:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0100a38:	eb 4b                	jmp    f0100a85 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100a3a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a3d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100a40:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100a44:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a47:	76 11                	jbe    f0100a5a <stab_binsearch+0x79>
			*region_left = m;
f0100a49:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100a4c:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100a4e:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a51:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a58:	eb 2b                	jmp    f0100a85 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100a5a:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a5d:	73 14                	jae    f0100a73 <stab_binsearch+0x92>
			*region_right = m - 1;
f0100a5f:	83 e8 01             	sub    $0x1,%eax
f0100a62:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a65:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a68:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a6a:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a71:	eb 12                	jmp    f0100a85 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a73:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a76:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100a78:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100a7c:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a7e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100a85:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100a88:	0f 8e 78 ff ff ff    	jle    f0100a06 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100a8e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100a92:	75 0f                	jne    f0100aa3 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0100a94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a97:	8b 00                	mov    (%eax),%eax
f0100a99:	83 e8 01             	sub    $0x1,%eax
f0100a9c:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a9f:	89 06                	mov    %eax,(%esi)
f0100aa1:	eb 2c                	jmp    f0100acf <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100aa3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100aa6:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100aa8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100aab:	8b 0e                	mov    (%esi),%ecx
f0100aad:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100ab0:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100ab3:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100ab6:	eb 03                	jmp    f0100abb <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100ab8:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100abb:	39 c8                	cmp    %ecx,%eax
f0100abd:	7e 0b                	jle    f0100aca <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0100abf:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100ac3:	83 ea 0c             	sub    $0xc,%edx
f0100ac6:	39 df                	cmp    %ebx,%edi
f0100ac8:	75 ee                	jne    f0100ab8 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100aca:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100acd:	89 06                	mov    %eax,(%esi)
	}
}
f0100acf:	83 c4 14             	add    $0x14,%esp
f0100ad2:	5b                   	pop    %ebx
f0100ad3:	5e                   	pop    %esi
f0100ad4:	5f                   	pop    %edi
f0100ad5:	5d                   	pop    %ebp
f0100ad6:	c3                   	ret    

f0100ad7 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100ad7:	55                   	push   %ebp
f0100ad8:	89 e5                	mov    %esp,%ebp
f0100ada:	57                   	push   %edi
f0100adb:	56                   	push   %esi
f0100adc:	53                   	push   %ebx
f0100add:	83 ec 3c             	sub    $0x3c,%esp
f0100ae0:	8b 75 08             	mov    0x8(%ebp),%esi
f0100ae3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100ae6:	c7 03 5c 1e 10 f0    	movl   $0xf0101e5c,(%ebx)
	info->eip_line = 0;
f0100aec:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100af3:	c7 43 08 5c 1e 10 f0 	movl   $0xf0101e5c,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100afa:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100b01:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100b04:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100b0b:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100b11:	76 11                	jbe    f0100b24 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b13:	b8 ab 73 10 f0       	mov    $0xf01073ab,%eax
f0100b18:	3d 85 5a 10 f0       	cmp    $0xf0105a85,%eax
f0100b1d:	77 19                	ja     f0100b38 <debuginfo_eip+0x61>
f0100b1f:	e9 a1 01 00 00       	jmp    f0100cc5 <debuginfo_eip+0x1ee>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100b24:	83 ec 04             	sub    $0x4,%esp
f0100b27:	68 66 1e 10 f0       	push   $0xf0101e66
f0100b2c:	6a 7f                	push   $0x7f
f0100b2e:	68 73 1e 10 f0       	push   $0xf0101e73
f0100b33:	e8 ea f5 ff ff       	call   f0100122 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b38:	80 3d aa 73 10 f0 00 	cmpb   $0x0,0xf01073aa
f0100b3f:	0f 85 87 01 00 00    	jne    f0100ccc <debuginfo_eip+0x1f5>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100b45:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100b4c:	b8 84 5a 10 f0       	mov    $0xf0105a84,%eax
f0100b51:	2d 94 20 10 f0       	sub    $0xf0102094,%eax
f0100b56:	c1 f8 02             	sar    $0x2,%eax
f0100b59:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100b5f:	83 e8 01             	sub    $0x1,%eax
f0100b62:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100b65:	83 ec 08             	sub    $0x8,%esp
f0100b68:	56                   	push   %esi
f0100b69:	6a 64                	push   $0x64
f0100b6b:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100b6e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100b71:	b8 94 20 10 f0       	mov    $0xf0102094,%eax
f0100b76:	e8 66 fe ff ff       	call   f01009e1 <stab_binsearch>
	if (lfile == 0)
f0100b7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b7e:	83 c4 10             	add    $0x10,%esp
f0100b81:	85 c0                	test   %eax,%eax
f0100b83:	0f 84 4a 01 00 00    	je     f0100cd3 <debuginfo_eip+0x1fc>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100b89:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100b8c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b8f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100b92:	83 ec 08             	sub    $0x8,%esp
f0100b95:	56                   	push   %esi
f0100b96:	6a 24                	push   $0x24
f0100b98:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100b9b:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b9e:	b8 94 20 10 f0       	mov    $0xf0102094,%eax
f0100ba3:	e8 39 fe ff ff       	call   f01009e1 <stab_binsearch>

	if (lfun <= rfun) {
f0100ba8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100bab:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100bae:	83 c4 10             	add    $0x10,%esp
f0100bb1:	39 d0                	cmp    %edx,%eax
f0100bb3:	7f 40                	jg     f0100bf5 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100bb5:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100bb8:	c1 e1 02             	shl    $0x2,%ecx
f0100bbb:	8d b9 94 20 10 f0    	lea    -0xfefdf6c(%ecx),%edi
f0100bc1:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100bc4:	8b b9 94 20 10 f0    	mov    -0xfefdf6c(%ecx),%edi
f0100bca:	b9 ab 73 10 f0       	mov    $0xf01073ab,%ecx
f0100bcf:	81 e9 85 5a 10 f0    	sub    $0xf0105a85,%ecx
f0100bd5:	39 cf                	cmp    %ecx,%edi
f0100bd7:	73 09                	jae    f0100be2 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100bd9:	81 c7 85 5a 10 f0    	add    $0xf0105a85,%edi
f0100bdf:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100be2:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100be5:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100be8:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100beb:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100bed:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100bf0:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100bf3:	eb 0f                	jmp    f0100c04 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100bf5:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100bf8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bfb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100bfe:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c01:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100c04:	83 ec 08             	sub    $0x8,%esp
f0100c07:	6a 3a                	push   $0x3a
f0100c09:	ff 73 08             	pushl  0x8(%ebx)
f0100c0c:	e8 49 08 00 00       	call   f010145a <strfind>
f0100c11:	2b 43 08             	sub    0x8(%ebx),%eax
f0100c14:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100c17:	83 c4 08             	add    $0x8,%esp
f0100c1a:	56                   	push   %esi
f0100c1b:	6a 44                	push   $0x44
f0100c1d:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100c20:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100c23:	b8 94 20 10 f0       	mov    $0xf0102094,%eax
f0100c28:	e8 b4 fd ff ff       	call   f01009e1 <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0100c2d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100c30:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100c33:	8d 04 85 94 20 10 f0 	lea    -0xfefdf6c(,%eax,4),%eax
f0100c3a:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f0100c3e:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c41:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100c44:	83 c4 10             	add    $0x10,%esp
f0100c47:	eb 06                	jmp    f0100c4f <debuginfo_eip+0x178>
f0100c49:	83 ea 01             	sub    $0x1,%edx
f0100c4c:	83 e8 0c             	sub    $0xc,%eax
f0100c4f:	39 d6                	cmp    %edx,%esi
f0100c51:	7f 34                	jg     f0100c87 <debuginfo_eip+0x1b0>
	       && stabs[lline].n_type != N_SOL
f0100c53:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0100c57:	80 f9 84             	cmp    $0x84,%cl
f0100c5a:	74 0b                	je     f0100c67 <debuginfo_eip+0x190>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100c5c:	80 f9 64             	cmp    $0x64,%cl
f0100c5f:	75 e8                	jne    f0100c49 <debuginfo_eip+0x172>
f0100c61:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100c65:	74 e2                	je     f0100c49 <debuginfo_eip+0x172>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100c67:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100c6a:	8b 14 85 94 20 10 f0 	mov    -0xfefdf6c(,%eax,4),%edx
f0100c71:	b8 ab 73 10 f0       	mov    $0xf01073ab,%eax
f0100c76:	2d 85 5a 10 f0       	sub    $0xf0105a85,%eax
f0100c7b:	39 c2                	cmp    %eax,%edx
f0100c7d:	73 08                	jae    f0100c87 <debuginfo_eip+0x1b0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100c7f:	81 c2 85 5a 10 f0    	add    $0xf0105a85,%edx
f0100c85:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c87:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c8a:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c8d:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c92:	39 f2                	cmp    %esi,%edx
f0100c94:	7d 49                	jge    f0100cdf <debuginfo_eip+0x208>
		for (lline = lfun + 1;
f0100c96:	83 c2 01             	add    $0x1,%edx
f0100c99:	89 d0                	mov    %edx,%eax
f0100c9b:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100c9e:	8d 14 95 94 20 10 f0 	lea    -0xfefdf6c(,%edx,4),%edx
f0100ca5:	eb 04                	jmp    f0100cab <debuginfo_eip+0x1d4>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100ca7:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100cab:	39 c6                	cmp    %eax,%esi
f0100cad:	7e 2b                	jle    f0100cda <debuginfo_eip+0x203>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100caf:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100cb3:	83 c0 01             	add    $0x1,%eax
f0100cb6:	83 c2 0c             	add    $0xc,%edx
f0100cb9:	80 f9 a0             	cmp    $0xa0,%cl
f0100cbc:	74 e9                	je     f0100ca7 <debuginfo_eip+0x1d0>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100cbe:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cc3:	eb 1a                	jmp    f0100cdf <debuginfo_eip+0x208>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100cc5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cca:	eb 13                	jmp    f0100cdf <debuginfo_eip+0x208>
f0100ccc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cd1:	eb 0c                	jmp    f0100cdf <debuginfo_eip+0x208>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100cd3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cd8:	eb 05                	jmp    f0100cdf <debuginfo_eip+0x208>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100cda:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100cdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ce2:	5b                   	pop    %ebx
f0100ce3:	5e                   	pop    %esi
f0100ce4:	5f                   	pop    %edi
f0100ce5:	5d                   	pop    %ebp
f0100ce6:	c3                   	ret    

f0100ce7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100ce7:	55                   	push   %ebp
f0100ce8:	89 e5                	mov    %esp,%ebp
f0100cea:	57                   	push   %edi
f0100ceb:	56                   	push   %esi
f0100cec:	53                   	push   %ebx
f0100ced:	83 ec 1c             	sub    $0x1c,%esp
f0100cf0:	89 c7                	mov    %eax,%edi
f0100cf2:	89 d6                	mov    %edx,%esi
f0100cf4:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cf7:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100cfa:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100cfd:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100d00:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100d03:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100d08:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100d0b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100d0e:	39 d3                	cmp    %edx,%ebx
f0100d10:	72 05                	jb     f0100d17 <printnum+0x30>
f0100d12:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100d15:	77 45                	ja     f0100d5c <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100d17:	83 ec 0c             	sub    $0xc,%esp
f0100d1a:	ff 75 18             	pushl  0x18(%ebp)
f0100d1d:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d20:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100d23:	53                   	push   %ebx
f0100d24:	ff 75 10             	pushl  0x10(%ebp)
f0100d27:	83 ec 08             	sub    $0x8,%esp
f0100d2a:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d2d:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d30:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d33:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d36:	e8 45 09 00 00       	call   f0101680 <__udivdi3>
f0100d3b:	83 c4 18             	add    $0x18,%esp
f0100d3e:	52                   	push   %edx
f0100d3f:	50                   	push   %eax
f0100d40:	89 f2                	mov    %esi,%edx
f0100d42:	89 f8                	mov    %edi,%eax
f0100d44:	e8 9e ff ff ff       	call   f0100ce7 <printnum>
f0100d49:	83 c4 20             	add    $0x20,%esp
f0100d4c:	eb 18                	jmp    f0100d66 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100d4e:	83 ec 08             	sub    $0x8,%esp
f0100d51:	56                   	push   %esi
f0100d52:	ff 75 18             	pushl  0x18(%ebp)
f0100d55:	ff d7                	call   *%edi
f0100d57:	83 c4 10             	add    $0x10,%esp
f0100d5a:	eb 03                	jmp    f0100d5f <printnum+0x78>
f0100d5c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100d5f:	83 eb 01             	sub    $0x1,%ebx
f0100d62:	85 db                	test   %ebx,%ebx
f0100d64:	7f e8                	jg     f0100d4e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100d66:	83 ec 08             	sub    $0x8,%esp
f0100d69:	56                   	push   %esi
f0100d6a:	83 ec 04             	sub    $0x4,%esp
f0100d6d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d70:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d73:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d76:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d79:	e8 32 0a 00 00       	call   f01017b0 <__umoddi3>
f0100d7e:	83 c4 14             	add    $0x14,%esp
f0100d81:	0f be 80 81 1e 10 f0 	movsbl -0xfefe17f(%eax),%eax
f0100d88:	50                   	push   %eax
f0100d89:	ff d7                	call   *%edi
}
f0100d8b:	83 c4 10             	add    $0x10,%esp
f0100d8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d91:	5b                   	pop    %ebx
f0100d92:	5e                   	pop    %esi
f0100d93:	5f                   	pop    %edi
f0100d94:	5d                   	pop    %ebp
f0100d95:	c3                   	ret    

f0100d96 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100d96:	55                   	push   %ebp
f0100d97:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100d99:	83 fa 01             	cmp    $0x1,%edx
f0100d9c:	7e 0e                	jle    f0100dac <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100d9e:	8b 10                	mov    (%eax),%edx
f0100da0:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100da3:	89 08                	mov    %ecx,(%eax)
f0100da5:	8b 02                	mov    (%edx),%eax
f0100da7:	8b 52 04             	mov    0x4(%edx),%edx
f0100daa:	eb 22                	jmp    f0100dce <getuint+0x38>
	else if (lflag)
f0100dac:	85 d2                	test   %edx,%edx
f0100dae:	74 10                	je     f0100dc0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100db0:	8b 10                	mov    (%eax),%edx
f0100db2:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100db5:	89 08                	mov    %ecx,(%eax)
f0100db7:	8b 02                	mov    (%edx),%eax
f0100db9:	ba 00 00 00 00       	mov    $0x0,%edx
f0100dbe:	eb 0e                	jmp    f0100dce <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100dc0:	8b 10                	mov    (%eax),%edx
f0100dc2:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100dc5:	89 08                	mov    %ecx,(%eax)
f0100dc7:	8b 02                	mov    (%edx),%eax
f0100dc9:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100dce:	5d                   	pop    %ebp
f0100dcf:	c3                   	ret    

f0100dd0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100dd0:	55                   	push   %ebp
f0100dd1:	89 e5                	mov    %esp,%ebp
f0100dd3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100dd6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100dda:	8b 10                	mov    (%eax),%edx
f0100ddc:	3b 50 04             	cmp    0x4(%eax),%edx
f0100ddf:	73 0a                	jae    f0100deb <sprintputch+0x1b>
		*b->buf++ = ch;
f0100de1:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100de4:	89 08                	mov    %ecx,(%eax)
f0100de6:	8b 45 08             	mov    0x8(%ebp),%eax
f0100de9:	88 02                	mov    %al,(%edx)
}
f0100deb:	5d                   	pop    %ebp
f0100dec:	c3                   	ret    

f0100ded <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100ded:	55                   	push   %ebp
f0100dee:	89 e5                	mov    %esp,%ebp
f0100df0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100df3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100df6:	50                   	push   %eax
f0100df7:	ff 75 10             	pushl  0x10(%ebp)
f0100dfa:	ff 75 0c             	pushl  0xc(%ebp)
f0100dfd:	ff 75 08             	pushl  0x8(%ebp)
f0100e00:	e8 05 00 00 00       	call   f0100e0a <vprintfmt>
	va_end(ap);
}
f0100e05:	83 c4 10             	add    $0x10,%esp
f0100e08:	c9                   	leave  
f0100e09:	c3                   	ret    

f0100e0a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100e0a:	55                   	push   %ebp
f0100e0b:	89 e5                	mov    %esp,%ebp
f0100e0d:	57                   	push   %edi
f0100e0e:	56                   	push   %esi
f0100e0f:	53                   	push   %ebx
f0100e10:	83 ec 2c             	sub    $0x2c,%esp
f0100e13:	8b 75 08             	mov    0x8(%ebp),%esi
f0100e16:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100e19:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100e1c:	eb 12                	jmp    f0100e30 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100e1e:	85 c0                	test   %eax,%eax
f0100e20:	0f 84 89 03 00 00    	je     f01011af <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0100e26:	83 ec 08             	sub    $0x8,%esp
f0100e29:	53                   	push   %ebx
f0100e2a:	50                   	push   %eax
f0100e2b:	ff d6                	call   *%esi
f0100e2d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100e30:	83 c7 01             	add    $0x1,%edi
f0100e33:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100e37:	83 f8 25             	cmp    $0x25,%eax
f0100e3a:	75 e2                	jne    f0100e1e <vprintfmt+0x14>
f0100e3c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100e40:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100e47:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100e4e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0100e55:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e5a:	eb 07                	jmp    f0100e63 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e5c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100e5f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e63:	8d 47 01             	lea    0x1(%edi),%eax
f0100e66:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100e69:	0f b6 07             	movzbl (%edi),%eax
f0100e6c:	0f b6 c8             	movzbl %al,%ecx
f0100e6f:	83 e8 23             	sub    $0x23,%eax
f0100e72:	3c 55                	cmp    $0x55,%al
f0100e74:	0f 87 1a 03 00 00    	ja     f0101194 <vprintfmt+0x38a>
f0100e7a:	0f b6 c0             	movzbl %al,%eax
f0100e7d:	ff 24 85 10 1f 10 f0 	jmp    *-0xfefe0f0(,%eax,4)
f0100e84:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100e87:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100e8b:	eb d6                	jmp    f0100e63 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e8d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e90:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e95:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100e98:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100e9b:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0100e9f:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0100ea2:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0100ea5:	83 fa 09             	cmp    $0x9,%edx
f0100ea8:	77 39                	ja     f0100ee3 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100eaa:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100ead:	eb e9                	jmp    f0100e98 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100eaf:	8b 45 14             	mov    0x14(%ebp),%eax
f0100eb2:	8d 48 04             	lea    0x4(%eax),%ecx
f0100eb5:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100eb8:	8b 00                	mov    (%eax),%eax
f0100eba:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ebd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100ec0:	eb 27                	jmp    f0100ee9 <vprintfmt+0xdf>
f0100ec2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ec5:	85 c0                	test   %eax,%eax
f0100ec7:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100ecc:	0f 49 c8             	cmovns %eax,%ecx
f0100ecf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ed2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100ed5:	eb 8c                	jmp    f0100e63 <vprintfmt+0x59>
f0100ed7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100eda:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100ee1:	eb 80                	jmp    f0100e63 <vprintfmt+0x59>
f0100ee3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100ee6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0100ee9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100eed:	0f 89 70 ff ff ff    	jns    f0100e63 <vprintfmt+0x59>
				width = precision, precision = -1;
f0100ef3:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100ef6:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100ef9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100f00:	e9 5e ff ff ff       	jmp    f0100e63 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100f05:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f08:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100f0b:	e9 53 ff ff ff       	jmp    f0100e63 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100f10:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f13:	8d 50 04             	lea    0x4(%eax),%edx
f0100f16:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f19:	83 ec 08             	sub    $0x8,%esp
f0100f1c:	53                   	push   %ebx
f0100f1d:	ff 30                	pushl  (%eax)
f0100f1f:	ff d6                	call   *%esi
			break;
f0100f21:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f24:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100f27:	e9 04 ff ff ff       	jmp    f0100e30 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100f2c:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f2f:	8d 50 04             	lea    0x4(%eax),%edx
f0100f32:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f35:	8b 00                	mov    (%eax),%eax
f0100f37:	99                   	cltd   
f0100f38:	31 d0                	xor    %edx,%eax
f0100f3a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100f3c:	83 f8 06             	cmp    $0x6,%eax
f0100f3f:	7f 0b                	jg     f0100f4c <vprintfmt+0x142>
f0100f41:	8b 14 85 68 20 10 f0 	mov    -0xfefdf98(,%eax,4),%edx
f0100f48:	85 d2                	test   %edx,%edx
f0100f4a:	75 18                	jne    f0100f64 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0100f4c:	50                   	push   %eax
f0100f4d:	68 99 1e 10 f0       	push   $0xf0101e99
f0100f52:	53                   	push   %ebx
f0100f53:	56                   	push   %esi
f0100f54:	e8 94 fe ff ff       	call   f0100ded <printfmt>
f0100f59:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f5c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100f5f:	e9 cc fe ff ff       	jmp    f0100e30 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0100f64:	52                   	push   %edx
f0100f65:	68 a2 1e 10 f0       	push   $0xf0101ea2
f0100f6a:	53                   	push   %ebx
f0100f6b:	56                   	push   %esi
f0100f6c:	e8 7c fe ff ff       	call   f0100ded <printfmt>
f0100f71:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f74:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f77:	e9 b4 fe ff ff       	jmp    f0100e30 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100f7c:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f7f:	8d 50 04             	lea    0x4(%eax),%edx
f0100f82:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f85:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0100f87:	85 ff                	test   %edi,%edi
f0100f89:	b8 92 1e 10 f0       	mov    $0xf0101e92,%eax
f0100f8e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0100f91:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100f95:	0f 8e 94 00 00 00    	jle    f010102f <vprintfmt+0x225>
f0100f9b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100f9f:	0f 84 98 00 00 00    	je     f010103d <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100fa5:	83 ec 08             	sub    $0x8,%esp
f0100fa8:	ff 75 d0             	pushl  -0x30(%ebp)
f0100fab:	57                   	push   %edi
f0100fac:	e8 5f 03 00 00       	call   f0101310 <strnlen>
f0100fb1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100fb4:	29 c1                	sub    %eax,%ecx
f0100fb6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0100fb9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0100fbc:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0100fc0:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100fc3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100fc6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100fc8:	eb 0f                	jmp    f0100fd9 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0100fca:	83 ec 08             	sub    $0x8,%esp
f0100fcd:	53                   	push   %ebx
f0100fce:	ff 75 e0             	pushl  -0x20(%ebp)
f0100fd1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100fd3:	83 ef 01             	sub    $0x1,%edi
f0100fd6:	83 c4 10             	add    $0x10,%esp
f0100fd9:	85 ff                	test   %edi,%edi
f0100fdb:	7f ed                	jg     f0100fca <vprintfmt+0x1c0>
f0100fdd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100fe0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0100fe3:	85 c9                	test   %ecx,%ecx
f0100fe5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fea:	0f 49 c1             	cmovns %ecx,%eax
f0100fed:	29 c1                	sub    %eax,%ecx
f0100fef:	89 75 08             	mov    %esi,0x8(%ebp)
f0100ff2:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100ff5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100ff8:	89 cb                	mov    %ecx,%ebx
f0100ffa:	eb 4d                	jmp    f0101049 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100ffc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0101000:	74 1b                	je     f010101d <vprintfmt+0x213>
f0101002:	0f be c0             	movsbl %al,%eax
f0101005:	83 e8 20             	sub    $0x20,%eax
f0101008:	83 f8 5e             	cmp    $0x5e,%eax
f010100b:	76 10                	jbe    f010101d <vprintfmt+0x213>
					putch('?', putdat);
f010100d:	83 ec 08             	sub    $0x8,%esp
f0101010:	ff 75 0c             	pushl  0xc(%ebp)
f0101013:	6a 3f                	push   $0x3f
f0101015:	ff 55 08             	call   *0x8(%ebp)
f0101018:	83 c4 10             	add    $0x10,%esp
f010101b:	eb 0d                	jmp    f010102a <vprintfmt+0x220>
				else
					putch(ch, putdat);
f010101d:	83 ec 08             	sub    $0x8,%esp
f0101020:	ff 75 0c             	pushl  0xc(%ebp)
f0101023:	52                   	push   %edx
f0101024:	ff 55 08             	call   *0x8(%ebp)
f0101027:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010102a:	83 eb 01             	sub    $0x1,%ebx
f010102d:	eb 1a                	jmp    f0101049 <vprintfmt+0x23f>
f010102f:	89 75 08             	mov    %esi,0x8(%ebp)
f0101032:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101035:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101038:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010103b:	eb 0c                	jmp    f0101049 <vprintfmt+0x23f>
f010103d:	89 75 08             	mov    %esi,0x8(%ebp)
f0101040:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101043:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101046:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101049:	83 c7 01             	add    $0x1,%edi
f010104c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101050:	0f be d0             	movsbl %al,%edx
f0101053:	85 d2                	test   %edx,%edx
f0101055:	74 23                	je     f010107a <vprintfmt+0x270>
f0101057:	85 f6                	test   %esi,%esi
f0101059:	78 a1                	js     f0100ffc <vprintfmt+0x1f2>
f010105b:	83 ee 01             	sub    $0x1,%esi
f010105e:	79 9c                	jns    f0100ffc <vprintfmt+0x1f2>
f0101060:	89 df                	mov    %ebx,%edi
f0101062:	8b 75 08             	mov    0x8(%ebp),%esi
f0101065:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101068:	eb 18                	jmp    f0101082 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010106a:	83 ec 08             	sub    $0x8,%esp
f010106d:	53                   	push   %ebx
f010106e:	6a 20                	push   $0x20
f0101070:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101072:	83 ef 01             	sub    $0x1,%edi
f0101075:	83 c4 10             	add    $0x10,%esp
f0101078:	eb 08                	jmp    f0101082 <vprintfmt+0x278>
f010107a:	89 df                	mov    %ebx,%edi
f010107c:	8b 75 08             	mov    0x8(%ebp),%esi
f010107f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101082:	85 ff                	test   %edi,%edi
f0101084:	7f e4                	jg     f010106a <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101086:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101089:	e9 a2 fd ff ff       	jmp    f0100e30 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010108e:	83 fa 01             	cmp    $0x1,%edx
f0101091:	7e 16                	jle    f01010a9 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0101093:	8b 45 14             	mov    0x14(%ebp),%eax
f0101096:	8d 50 08             	lea    0x8(%eax),%edx
f0101099:	89 55 14             	mov    %edx,0x14(%ebp)
f010109c:	8b 50 04             	mov    0x4(%eax),%edx
f010109f:	8b 00                	mov    (%eax),%eax
f01010a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010a4:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01010a7:	eb 32                	jmp    f01010db <vprintfmt+0x2d1>
	else if (lflag)
f01010a9:	85 d2                	test   %edx,%edx
f01010ab:	74 18                	je     f01010c5 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f01010ad:	8b 45 14             	mov    0x14(%ebp),%eax
f01010b0:	8d 50 04             	lea    0x4(%eax),%edx
f01010b3:	89 55 14             	mov    %edx,0x14(%ebp)
f01010b6:	8b 00                	mov    (%eax),%eax
f01010b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010bb:	89 c1                	mov    %eax,%ecx
f01010bd:	c1 f9 1f             	sar    $0x1f,%ecx
f01010c0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01010c3:	eb 16                	jmp    f01010db <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f01010c5:	8b 45 14             	mov    0x14(%ebp),%eax
f01010c8:	8d 50 04             	lea    0x4(%eax),%edx
f01010cb:	89 55 14             	mov    %edx,0x14(%ebp)
f01010ce:	8b 00                	mov    (%eax),%eax
f01010d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010d3:	89 c1                	mov    %eax,%ecx
f01010d5:	c1 f9 1f             	sar    $0x1f,%ecx
f01010d8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01010db:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010de:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01010e1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01010e6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01010ea:	79 74                	jns    f0101160 <vprintfmt+0x356>
				putch('-', putdat);
f01010ec:	83 ec 08             	sub    $0x8,%esp
f01010ef:	53                   	push   %ebx
f01010f0:	6a 2d                	push   $0x2d
f01010f2:	ff d6                	call   *%esi
				num = -(long long) num;
f01010f4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010f7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01010fa:	f7 d8                	neg    %eax
f01010fc:	83 d2 00             	adc    $0x0,%edx
f01010ff:	f7 da                	neg    %edx
f0101101:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0101104:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0101109:	eb 55                	jmp    f0101160 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010110b:	8d 45 14             	lea    0x14(%ebp),%eax
f010110e:	e8 83 fc ff ff       	call   f0100d96 <getuint>
			base = 10;
f0101113:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0101118:	eb 46                	jmp    f0101160 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num=getuint(&ap,lflag);
f010111a:	8d 45 14             	lea    0x14(%ebp),%eax
f010111d:	e8 74 fc ff ff       	call   f0100d96 <getuint>
			base=8;
f0101122:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0101127:	eb 37                	jmp    f0101160 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0101129:	83 ec 08             	sub    $0x8,%esp
f010112c:	53                   	push   %ebx
f010112d:	6a 30                	push   $0x30
f010112f:	ff d6                	call   *%esi
			putch('x', putdat);
f0101131:	83 c4 08             	add    $0x8,%esp
f0101134:	53                   	push   %ebx
f0101135:	6a 78                	push   $0x78
f0101137:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0101139:	8b 45 14             	mov    0x14(%ebp),%eax
f010113c:	8d 50 04             	lea    0x4(%eax),%edx
f010113f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0101142:	8b 00                	mov    (%eax),%eax
f0101144:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0101149:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010114c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0101151:	eb 0d                	jmp    f0101160 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0101153:	8d 45 14             	lea    0x14(%ebp),%eax
f0101156:	e8 3b fc ff ff       	call   f0100d96 <getuint>
			base = 16;
f010115b:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0101160:	83 ec 0c             	sub    $0xc,%esp
f0101163:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0101167:	57                   	push   %edi
f0101168:	ff 75 e0             	pushl  -0x20(%ebp)
f010116b:	51                   	push   %ecx
f010116c:	52                   	push   %edx
f010116d:	50                   	push   %eax
f010116e:	89 da                	mov    %ebx,%edx
f0101170:	89 f0                	mov    %esi,%eax
f0101172:	e8 70 fb ff ff       	call   f0100ce7 <printnum>
			break;
f0101177:	83 c4 20             	add    $0x20,%esp
f010117a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010117d:	e9 ae fc ff ff       	jmp    f0100e30 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101182:	83 ec 08             	sub    $0x8,%esp
f0101185:	53                   	push   %ebx
f0101186:	51                   	push   %ecx
f0101187:	ff d6                	call   *%esi
			break;
f0101189:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010118c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010118f:	e9 9c fc ff ff       	jmp    f0100e30 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101194:	83 ec 08             	sub    $0x8,%esp
f0101197:	53                   	push   %ebx
f0101198:	6a 25                	push   $0x25
f010119a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010119c:	83 c4 10             	add    $0x10,%esp
f010119f:	eb 03                	jmp    f01011a4 <vprintfmt+0x39a>
f01011a1:	83 ef 01             	sub    $0x1,%edi
f01011a4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01011a8:	75 f7                	jne    f01011a1 <vprintfmt+0x397>
f01011aa:	e9 81 fc ff ff       	jmp    f0100e30 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f01011af:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011b2:	5b                   	pop    %ebx
f01011b3:	5e                   	pop    %esi
f01011b4:	5f                   	pop    %edi
f01011b5:	5d                   	pop    %ebp
f01011b6:	c3                   	ret    

f01011b7 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01011b7:	55                   	push   %ebp
f01011b8:	89 e5                	mov    %esp,%ebp
f01011ba:	83 ec 18             	sub    $0x18,%esp
f01011bd:	8b 45 08             	mov    0x8(%ebp),%eax
f01011c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01011c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01011c6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01011ca:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01011cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01011d4:	85 c0                	test   %eax,%eax
f01011d6:	74 26                	je     f01011fe <vsnprintf+0x47>
f01011d8:	85 d2                	test   %edx,%edx
f01011da:	7e 22                	jle    f01011fe <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01011dc:	ff 75 14             	pushl  0x14(%ebp)
f01011df:	ff 75 10             	pushl  0x10(%ebp)
f01011e2:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01011e5:	50                   	push   %eax
f01011e6:	68 d0 0d 10 f0       	push   $0xf0100dd0
f01011eb:	e8 1a fc ff ff       	call   f0100e0a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01011f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01011f3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01011f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011f9:	83 c4 10             	add    $0x10,%esp
f01011fc:	eb 05                	jmp    f0101203 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01011fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101203:	c9                   	leave  
f0101204:	c3                   	ret    

f0101205 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101205:	55                   	push   %ebp
f0101206:	89 e5                	mov    %esp,%ebp
f0101208:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010120b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010120e:	50                   	push   %eax
f010120f:	ff 75 10             	pushl  0x10(%ebp)
f0101212:	ff 75 0c             	pushl  0xc(%ebp)
f0101215:	ff 75 08             	pushl  0x8(%ebp)
f0101218:	e8 9a ff ff ff       	call   f01011b7 <vsnprintf>
	va_end(ap);

	return rc;
}
f010121d:	c9                   	leave  
f010121e:	c3                   	ret    

f010121f <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010121f:	55                   	push   %ebp
f0101220:	89 e5                	mov    %esp,%ebp
f0101222:	57                   	push   %edi
f0101223:	56                   	push   %esi
f0101224:	53                   	push   %ebx
f0101225:	83 ec 0c             	sub    $0xc,%esp
f0101228:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010122b:	85 c0                	test   %eax,%eax
f010122d:	74 11                	je     f0101240 <readline+0x21>
		cprintf("%s", prompt);
f010122f:	83 ec 08             	sub    $0x8,%esp
f0101232:	50                   	push   %eax
f0101233:	68 a2 1e 10 f0       	push   $0xf0101ea2
f0101238:	e8 90 f7 ff ff       	call   f01009cd <cprintf>
f010123d:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101240:	83 ec 0c             	sub    $0xc,%esp
f0101243:	6a 00                	push   $0x0
f0101245:	e8 6e f4 ff ff       	call   f01006b8 <iscons>
f010124a:	89 c7                	mov    %eax,%edi
f010124c:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010124f:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101254:	e8 4e f4 ff ff       	call   f01006a7 <getchar>
f0101259:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010125b:	85 c0                	test   %eax,%eax
f010125d:	79 18                	jns    f0101277 <readline+0x58>
			cprintf("read error: %e\n", c);
f010125f:	83 ec 08             	sub    $0x8,%esp
f0101262:	50                   	push   %eax
f0101263:	68 84 20 10 f0       	push   $0xf0102084
f0101268:	e8 60 f7 ff ff       	call   f01009cd <cprintf>
			return NULL;
f010126d:	83 c4 10             	add    $0x10,%esp
f0101270:	b8 00 00 00 00       	mov    $0x0,%eax
f0101275:	eb 79                	jmp    f01012f0 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101277:	83 f8 08             	cmp    $0x8,%eax
f010127a:	0f 94 c2             	sete   %dl
f010127d:	83 f8 7f             	cmp    $0x7f,%eax
f0101280:	0f 94 c0             	sete   %al
f0101283:	08 c2                	or     %al,%dl
f0101285:	74 1a                	je     f01012a1 <readline+0x82>
f0101287:	85 f6                	test   %esi,%esi
f0101289:	7e 16                	jle    f01012a1 <readline+0x82>
			if (echoing)
f010128b:	85 ff                	test   %edi,%edi
f010128d:	74 0d                	je     f010129c <readline+0x7d>
				cputchar('\b');
f010128f:	83 ec 0c             	sub    $0xc,%esp
f0101292:	6a 08                	push   $0x8
f0101294:	e8 fe f3 ff ff       	call   f0100697 <cputchar>
f0101299:	83 c4 10             	add    $0x10,%esp
			i--;
f010129c:	83 ee 01             	sub    $0x1,%esi
f010129f:	eb b3                	jmp    f0101254 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01012a1:	83 fb 1f             	cmp    $0x1f,%ebx
f01012a4:	7e 23                	jle    f01012c9 <readline+0xaa>
f01012a6:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01012ac:	7f 1b                	jg     f01012c9 <readline+0xaa>
			if (echoing)
f01012ae:	85 ff                	test   %edi,%edi
f01012b0:	74 0c                	je     f01012be <readline+0x9f>
				cputchar(c);
f01012b2:	83 ec 0c             	sub    $0xc,%esp
f01012b5:	53                   	push   %ebx
f01012b6:	e8 dc f3 ff ff       	call   f0100697 <cputchar>
f01012bb:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01012be:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f01012c4:	8d 76 01             	lea    0x1(%esi),%esi
f01012c7:	eb 8b                	jmp    f0101254 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01012c9:	83 fb 0a             	cmp    $0xa,%ebx
f01012cc:	74 05                	je     f01012d3 <readline+0xb4>
f01012ce:	83 fb 0d             	cmp    $0xd,%ebx
f01012d1:	75 81                	jne    f0101254 <readline+0x35>
			if (echoing)
f01012d3:	85 ff                	test   %edi,%edi
f01012d5:	74 0d                	je     f01012e4 <readline+0xc5>
				cputchar('\n');
f01012d7:	83 ec 0c             	sub    $0xc,%esp
f01012da:	6a 0a                	push   $0xa
f01012dc:	e8 b6 f3 ff ff       	call   f0100697 <cputchar>
f01012e1:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01012e4:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f01012eb:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f01012f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012f3:	5b                   	pop    %ebx
f01012f4:	5e                   	pop    %esi
f01012f5:	5f                   	pop    %edi
f01012f6:	5d                   	pop    %ebp
f01012f7:	c3                   	ret    

f01012f8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01012f8:	55                   	push   %ebp
f01012f9:	89 e5                	mov    %esp,%ebp
f01012fb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01012fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0101303:	eb 03                	jmp    f0101308 <strlen+0x10>
		n++;
f0101305:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101308:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010130c:	75 f7                	jne    f0101305 <strlen+0xd>
		n++;
	return n;
}
f010130e:	5d                   	pop    %ebp
f010130f:	c3                   	ret    

f0101310 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101310:	55                   	push   %ebp
f0101311:	89 e5                	mov    %esp,%ebp
f0101313:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101316:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101319:	ba 00 00 00 00       	mov    $0x0,%edx
f010131e:	eb 03                	jmp    f0101323 <strnlen+0x13>
		n++;
f0101320:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101323:	39 c2                	cmp    %eax,%edx
f0101325:	74 08                	je     f010132f <strnlen+0x1f>
f0101327:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010132b:	75 f3                	jne    f0101320 <strnlen+0x10>
f010132d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010132f:	5d                   	pop    %ebp
f0101330:	c3                   	ret    

f0101331 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101331:	55                   	push   %ebp
f0101332:	89 e5                	mov    %esp,%ebp
f0101334:	53                   	push   %ebx
f0101335:	8b 45 08             	mov    0x8(%ebp),%eax
f0101338:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010133b:	89 c2                	mov    %eax,%edx
f010133d:	83 c2 01             	add    $0x1,%edx
f0101340:	83 c1 01             	add    $0x1,%ecx
f0101343:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0101347:	88 5a ff             	mov    %bl,-0x1(%edx)
f010134a:	84 db                	test   %bl,%bl
f010134c:	75 ef                	jne    f010133d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010134e:	5b                   	pop    %ebx
f010134f:	5d                   	pop    %ebp
f0101350:	c3                   	ret    

f0101351 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101351:	55                   	push   %ebp
f0101352:	89 e5                	mov    %esp,%ebp
f0101354:	53                   	push   %ebx
f0101355:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101358:	53                   	push   %ebx
f0101359:	e8 9a ff ff ff       	call   f01012f8 <strlen>
f010135e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0101361:	ff 75 0c             	pushl  0xc(%ebp)
f0101364:	01 d8                	add    %ebx,%eax
f0101366:	50                   	push   %eax
f0101367:	e8 c5 ff ff ff       	call   f0101331 <strcpy>
	return dst;
}
f010136c:	89 d8                	mov    %ebx,%eax
f010136e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101371:	c9                   	leave  
f0101372:	c3                   	ret    

f0101373 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101373:	55                   	push   %ebp
f0101374:	89 e5                	mov    %esp,%ebp
f0101376:	56                   	push   %esi
f0101377:	53                   	push   %ebx
f0101378:	8b 75 08             	mov    0x8(%ebp),%esi
f010137b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010137e:	89 f3                	mov    %esi,%ebx
f0101380:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101383:	89 f2                	mov    %esi,%edx
f0101385:	eb 0f                	jmp    f0101396 <strncpy+0x23>
		*dst++ = *src;
f0101387:	83 c2 01             	add    $0x1,%edx
f010138a:	0f b6 01             	movzbl (%ecx),%eax
f010138d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101390:	80 39 01             	cmpb   $0x1,(%ecx)
f0101393:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101396:	39 da                	cmp    %ebx,%edx
f0101398:	75 ed                	jne    f0101387 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010139a:	89 f0                	mov    %esi,%eax
f010139c:	5b                   	pop    %ebx
f010139d:	5e                   	pop    %esi
f010139e:	5d                   	pop    %ebp
f010139f:	c3                   	ret    

f01013a0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01013a0:	55                   	push   %ebp
f01013a1:	89 e5                	mov    %esp,%ebp
f01013a3:	56                   	push   %esi
f01013a4:	53                   	push   %ebx
f01013a5:	8b 75 08             	mov    0x8(%ebp),%esi
f01013a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01013ab:	8b 55 10             	mov    0x10(%ebp),%edx
f01013ae:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01013b0:	85 d2                	test   %edx,%edx
f01013b2:	74 21                	je     f01013d5 <strlcpy+0x35>
f01013b4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01013b8:	89 f2                	mov    %esi,%edx
f01013ba:	eb 09                	jmp    f01013c5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01013bc:	83 c2 01             	add    $0x1,%edx
f01013bf:	83 c1 01             	add    $0x1,%ecx
f01013c2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01013c5:	39 c2                	cmp    %eax,%edx
f01013c7:	74 09                	je     f01013d2 <strlcpy+0x32>
f01013c9:	0f b6 19             	movzbl (%ecx),%ebx
f01013cc:	84 db                	test   %bl,%bl
f01013ce:	75 ec                	jne    f01013bc <strlcpy+0x1c>
f01013d0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01013d2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01013d5:	29 f0                	sub    %esi,%eax
}
f01013d7:	5b                   	pop    %ebx
f01013d8:	5e                   	pop    %esi
f01013d9:	5d                   	pop    %ebp
f01013da:	c3                   	ret    

f01013db <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01013db:	55                   	push   %ebp
f01013dc:	89 e5                	mov    %esp,%ebp
f01013de:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01013e1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01013e4:	eb 06                	jmp    f01013ec <strcmp+0x11>
		p++, q++;
f01013e6:	83 c1 01             	add    $0x1,%ecx
f01013e9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01013ec:	0f b6 01             	movzbl (%ecx),%eax
f01013ef:	84 c0                	test   %al,%al
f01013f1:	74 04                	je     f01013f7 <strcmp+0x1c>
f01013f3:	3a 02                	cmp    (%edx),%al
f01013f5:	74 ef                	je     f01013e6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01013f7:	0f b6 c0             	movzbl %al,%eax
f01013fa:	0f b6 12             	movzbl (%edx),%edx
f01013fd:	29 d0                	sub    %edx,%eax
}
f01013ff:	5d                   	pop    %ebp
f0101400:	c3                   	ret    

f0101401 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101401:	55                   	push   %ebp
f0101402:	89 e5                	mov    %esp,%ebp
f0101404:	53                   	push   %ebx
f0101405:	8b 45 08             	mov    0x8(%ebp),%eax
f0101408:	8b 55 0c             	mov    0xc(%ebp),%edx
f010140b:	89 c3                	mov    %eax,%ebx
f010140d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0101410:	eb 06                	jmp    f0101418 <strncmp+0x17>
		n--, p++, q++;
f0101412:	83 c0 01             	add    $0x1,%eax
f0101415:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101418:	39 d8                	cmp    %ebx,%eax
f010141a:	74 15                	je     f0101431 <strncmp+0x30>
f010141c:	0f b6 08             	movzbl (%eax),%ecx
f010141f:	84 c9                	test   %cl,%cl
f0101421:	74 04                	je     f0101427 <strncmp+0x26>
f0101423:	3a 0a                	cmp    (%edx),%cl
f0101425:	74 eb                	je     f0101412 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101427:	0f b6 00             	movzbl (%eax),%eax
f010142a:	0f b6 12             	movzbl (%edx),%edx
f010142d:	29 d0                	sub    %edx,%eax
f010142f:	eb 05                	jmp    f0101436 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101431:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101436:	5b                   	pop    %ebx
f0101437:	5d                   	pop    %ebp
f0101438:	c3                   	ret    

f0101439 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101439:	55                   	push   %ebp
f010143a:	89 e5                	mov    %esp,%ebp
f010143c:	8b 45 08             	mov    0x8(%ebp),%eax
f010143f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101443:	eb 07                	jmp    f010144c <strchr+0x13>
		if (*s == c)
f0101445:	38 ca                	cmp    %cl,%dl
f0101447:	74 0f                	je     f0101458 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101449:	83 c0 01             	add    $0x1,%eax
f010144c:	0f b6 10             	movzbl (%eax),%edx
f010144f:	84 d2                	test   %dl,%dl
f0101451:	75 f2                	jne    f0101445 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0101453:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101458:	5d                   	pop    %ebp
f0101459:	c3                   	ret    

f010145a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010145a:	55                   	push   %ebp
f010145b:	89 e5                	mov    %esp,%ebp
f010145d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101460:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101464:	eb 03                	jmp    f0101469 <strfind+0xf>
f0101466:	83 c0 01             	add    $0x1,%eax
f0101469:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010146c:	38 ca                	cmp    %cl,%dl
f010146e:	74 04                	je     f0101474 <strfind+0x1a>
f0101470:	84 d2                	test   %dl,%dl
f0101472:	75 f2                	jne    f0101466 <strfind+0xc>
			break;
	return (char *) s;
}
f0101474:	5d                   	pop    %ebp
f0101475:	c3                   	ret    

f0101476 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101476:	55                   	push   %ebp
f0101477:	89 e5                	mov    %esp,%ebp
f0101479:	57                   	push   %edi
f010147a:	56                   	push   %esi
f010147b:	53                   	push   %ebx
f010147c:	8b 7d 08             	mov    0x8(%ebp),%edi
f010147f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101482:	85 c9                	test   %ecx,%ecx
f0101484:	74 36                	je     f01014bc <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101486:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010148c:	75 28                	jne    f01014b6 <memset+0x40>
f010148e:	f6 c1 03             	test   $0x3,%cl
f0101491:	75 23                	jne    f01014b6 <memset+0x40>
		c &= 0xFF;
f0101493:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101497:	89 d3                	mov    %edx,%ebx
f0101499:	c1 e3 08             	shl    $0x8,%ebx
f010149c:	89 d6                	mov    %edx,%esi
f010149e:	c1 e6 18             	shl    $0x18,%esi
f01014a1:	89 d0                	mov    %edx,%eax
f01014a3:	c1 e0 10             	shl    $0x10,%eax
f01014a6:	09 f0                	or     %esi,%eax
f01014a8:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01014aa:	89 d8                	mov    %ebx,%eax
f01014ac:	09 d0                	or     %edx,%eax
f01014ae:	c1 e9 02             	shr    $0x2,%ecx
f01014b1:	fc                   	cld    
f01014b2:	f3 ab                	rep stos %eax,%es:(%edi)
f01014b4:	eb 06                	jmp    f01014bc <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01014b6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014b9:	fc                   	cld    
f01014ba:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01014bc:	89 f8                	mov    %edi,%eax
f01014be:	5b                   	pop    %ebx
f01014bf:	5e                   	pop    %esi
f01014c0:	5f                   	pop    %edi
f01014c1:	5d                   	pop    %ebp
f01014c2:	c3                   	ret    

f01014c3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01014c3:	55                   	push   %ebp
f01014c4:	89 e5                	mov    %esp,%ebp
f01014c6:	57                   	push   %edi
f01014c7:	56                   	push   %esi
f01014c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01014cb:	8b 75 0c             	mov    0xc(%ebp),%esi
f01014ce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01014d1:	39 c6                	cmp    %eax,%esi
f01014d3:	73 35                	jae    f010150a <memmove+0x47>
f01014d5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01014d8:	39 d0                	cmp    %edx,%eax
f01014da:	73 2e                	jae    f010150a <memmove+0x47>
		s += n;
		d += n;
f01014dc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01014df:	89 d6                	mov    %edx,%esi
f01014e1:	09 fe                	or     %edi,%esi
f01014e3:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01014e9:	75 13                	jne    f01014fe <memmove+0x3b>
f01014eb:	f6 c1 03             	test   $0x3,%cl
f01014ee:	75 0e                	jne    f01014fe <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01014f0:	83 ef 04             	sub    $0x4,%edi
f01014f3:	8d 72 fc             	lea    -0x4(%edx),%esi
f01014f6:	c1 e9 02             	shr    $0x2,%ecx
f01014f9:	fd                   	std    
f01014fa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01014fc:	eb 09                	jmp    f0101507 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01014fe:	83 ef 01             	sub    $0x1,%edi
f0101501:	8d 72 ff             	lea    -0x1(%edx),%esi
f0101504:	fd                   	std    
f0101505:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101507:	fc                   	cld    
f0101508:	eb 1d                	jmp    f0101527 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010150a:	89 f2                	mov    %esi,%edx
f010150c:	09 c2                	or     %eax,%edx
f010150e:	f6 c2 03             	test   $0x3,%dl
f0101511:	75 0f                	jne    f0101522 <memmove+0x5f>
f0101513:	f6 c1 03             	test   $0x3,%cl
f0101516:	75 0a                	jne    f0101522 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0101518:	c1 e9 02             	shr    $0x2,%ecx
f010151b:	89 c7                	mov    %eax,%edi
f010151d:	fc                   	cld    
f010151e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101520:	eb 05                	jmp    f0101527 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101522:	89 c7                	mov    %eax,%edi
f0101524:	fc                   	cld    
f0101525:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101527:	5e                   	pop    %esi
f0101528:	5f                   	pop    %edi
f0101529:	5d                   	pop    %ebp
f010152a:	c3                   	ret    

f010152b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010152b:	55                   	push   %ebp
f010152c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010152e:	ff 75 10             	pushl  0x10(%ebp)
f0101531:	ff 75 0c             	pushl  0xc(%ebp)
f0101534:	ff 75 08             	pushl  0x8(%ebp)
f0101537:	e8 87 ff ff ff       	call   f01014c3 <memmove>
}
f010153c:	c9                   	leave  
f010153d:	c3                   	ret    

f010153e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010153e:	55                   	push   %ebp
f010153f:	89 e5                	mov    %esp,%ebp
f0101541:	56                   	push   %esi
f0101542:	53                   	push   %ebx
f0101543:	8b 45 08             	mov    0x8(%ebp),%eax
f0101546:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101549:	89 c6                	mov    %eax,%esi
f010154b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010154e:	eb 1a                	jmp    f010156a <memcmp+0x2c>
		if (*s1 != *s2)
f0101550:	0f b6 08             	movzbl (%eax),%ecx
f0101553:	0f b6 1a             	movzbl (%edx),%ebx
f0101556:	38 d9                	cmp    %bl,%cl
f0101558:	74 0a                	je     f0101564 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010155a:	0f b6 c1             	movzbl %cl,%eax
f010155d:	0f b6 db             	movzbl %bl,%ebx
f0101560:	29 d8                	sub    %ebx,%eax
f0101562:	eb 0f                	jmp    f0101573 <memcmp+0x35>
		s1++, s2++;
f0101564:	83 c0 01             	add    $0x1,%eax
f0101567:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010156a:	39 f0                	cmp    %esi,%eax
f010156c:	75 e2                	jne    f0101550 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010156e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101573:	5b                   	pop    %ebx
f0101574:	5e                   	pop    %esi
f0101575:	5d                   	pop    %ebp
f0101576:	c3                   	ret    

f0101577 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101577:	55                   	push   %ebp
f0101578:	89 e5                	mov    %esp,%ebp
f010157a:	53                   	push   %ebx
f010157b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010157e:	89 c1                	mov    %eax,%ecx
f0101580:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0101583:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101587:	eb 0a                	jmp    f0101593 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101589:	0f b6 10             	movzbl (%eax),%edx
f010158c:	39 da                	cmp    %ebx,%edx
f010158e:	74 07                	je     f0101597 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101590:	83 c0 01             	add    $0x1,%eax
f0101593:	39 c8                	cmp    %ecx,%eax
f0101595:	72 f2                	jb     f0101589 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101597:	5b                   	pop    %ebx
f0101598:	5d                   	pop    %ebp
f0101599:	c3                   	ret    

f010159a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010159a:	55                   	push   %ebp
f010159b:	89 e5                	mov    %esp,%ebp
f010159d:	57                   	push   %edi
f010159e:	56                   	push   %esi
f010159f:	53                   	push   %ebx
f01015a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01015a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01015a6:	eb 03                	jmp    f01015ab <strtol+0x11>
		s++;
f01015a8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01015ab:	0f b6 01             	movzbl (%ecx),%eax
f01015ae:	3c 20                	cmp    $0x20,%al
f01015b0:	74 f6                	je     f01015a8 <strtol+0xe>
f01015b2:	3c 09                	cmp    $0x9,%al
f01015b4:	74 f2                	je     f01015a8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01015b6:	3c 2b                	cmp    $0x2b,%al
f01015b8:	75 0a                	jne    f01015c4 <strtol+0x2a>
		s++;
f01015ba:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01015bd:	bf 00 00 00 00       	mov    $0x0,%edi
f01015c2:	eb 11                	jmp    f01015d5 <strtol+0x3b>
f01015c4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01015c9:	3c 2d                	cmp    $0x2d,%al
f01015cb:	75 08                	jne    f01015d5 <strtol+0x3b>
		s++, neg = 1;
f01015cd:	83 c1 01             	add    $0x1,%ecx
f01015d0:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01015d5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01015db:	75 15                	jne    f01015f2 <strtol+0x58>
f01015dd:	80 39 30             	cmpb   $0x30,(%ecx)
f01015e0:	75 10                	jne    f01015f2 <strtol+0x58>
f01015e2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01015e6:	75 7c                	jne    f0101664 <strtol+0xca>
		s += 2, base = 16;
f01015e8:	83 c1 02             	add    $0x2,%ecx
f01015eb:	bb 10 00 00 00       	mov    $0x10,%ebx
f01015f0:	eb 16                	jmp    f0101608 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01015f2:	85 db                	test   %ebx,%ebx
f01015f4:	75 12                	jne    f0101608 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01015f6:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01015fb:	80 39 30             	cmpb   $0x30,(%ecx)
f01015fe:	75 08                	jne    f0101608 <strtol+0x6e>
		s++, base = 8;
f0101600:	83 c1 01             	add    $0x1,%ecx
f0101603:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0101608:	b8 00 00 00 00       	mov    $0x0,%eax
f010160d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101610:	0f b6 11             	movzbl (%ecx),%edx
f0101613:	8d 72 d0             	lea    -0x30(%edx),%esi
f0101616:	89 f3                	mov    %esi,%ebx
f0101618:	80 fb 09             	cmp    $0x9,%bl
f010161b:	77 08                	ja     f0101625 <strtol+0x8b>
			dig = *s - '0';
f010161d:	0f be d2             	movsbl %dl,%edx
f0101620:	83 ea 30             	sub    $0x30,%edx
f0101623:	eb 22                	jmp    f0101647 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0101625:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101628:	89 f3                	mov    %esi,%ebx
f010162a:	80 fb 19             	cmp    $0x19,%bl
f010162d:	77 08                	ja     f0101637 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010162f:	0f be d2             	movsbl %dl,%edx
f0101632:	83 ea 57             	sub    $0x57,%edx
f0101635:	eb 10                	jmp    f0101647 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0101637:	8d 72 bf             	lea    -0x41(%edx),%esi
f010163a:	89 f3                	mov    %esi,%ebx
f010163c:	80 fb 19             	cmp    $0x19,%bl
f010163f:	77 16                	ja     f0101657 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0101641:	0f be d2             	movsbl %dl,%edx
f0101644:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0101647:	3b 55 10             	cmp    0x10(%ebp),%edx
f010164a:	7d 0b                	jge    f0101657 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010164c:	83 c1 01             	add    $0x1,%ecx
f010164f:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101653:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0101655:	eb b9                	jmp    f0101610 <strtol+0x76>

	if (endptr)
f0101657:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010165b:	74 0d                	je     f010166a <strtol+0xd0>
		*endptr = (char *) s;
f010165d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101660:	89 0e                	mov    %ecx,(%esi)
f0101662:	eb 06                	jmp    f010166a <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101664:	85 db                	test   %ebx,%ebx
f0101666:	74 98                	je     f0101600 <strtol+0x66>
f0101668:	eb 9e                	jmp    f0101608 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010166a:	89 c2                	mov    %eax,%edx
f010166c:	f7 da                	neg    %edx
f010166e:	85 ff                	test   %edi,%edi
f0101670:	0f 45 c2             	cmovne %edx,%eax
}
f0101673:	5b                   	pop    %ebx
f0101674:	5e                   	pop    %esi
f0101675:	5f                   	pop    %edi
f0101676:	5d                   	pop    %ebp
f0101677:	c3                   	ret    
f0101678:	66 90                	xchg   %ax,%ax
f010167a:	66 90                	xchg   %ax,%ax
f010167c:	66 90                	xchg   %ax,%ax
f010167e:	66 90                	xchg   %ax,%ax

f0101680 <__udivdi3>:
f0101680:	55                   	push   %ebp
f0101681:	57                   	push   %edi
f0101682:	56                   	push   %esi
f0101683:	53                   	push   %ebx
f0101684:	83 ec 1c             	sub    $0x1c,%esp
f0101687:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010168b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010168f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0101693:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101697:	85 f6                	test   %esi,%esi
f0101699:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010169d:	89 ca                	mov    %ecx,%edx
f010169f:	89 f8                	mov    %edi,%eax
f01016a1:	75 3d                	jne    f01016e0 <__udivdi3+0x60>
f01016a3:	39 cf                	cmp    %ecx,%edi
f01016a5:	0f 87 c5 00 00 00    	ja     f0101770 <__udivdi3+0xf0>
f01016ab:	85 ff                	test   %edi,%edi
f01016ad:	89 fd                	mov    %edi,%ebp
f01016af:	75 0b                	jne    f01016bc <__udivdi3+0x3c>
f01016b1:	b8 01 00 00 00       	mov    $0x1,%eax
f01016b6:	31 d2                	xor    %edx,%edx
f01016b8:	f7 f7                	div    %edi
f01016ba:	89 c5                	mov    %eax,%ebp
f01016bc:	89 c8                	mov    %ecx,%eax
f01016be:	31 d2                	xor    %edx,%edx
f01016c0:	f7 f5                	div    %ebp
f01016c2:	89 c1                	mov    %eax,%ecx
f01016c4:	89 d8                	mov    %ebx,%eax
f01016c6:	89 cf                	mov    %ecx,%edi
f01016c8:	f7 f5                	div    %ebp
f01016ca:	89 c3                	mov    %eax,%ebx
f01016cc:	89 d8                	mov    %ebx,%eax
f01016ce:	89 fa                	mov    %edi,%edx
f01016d0:	83 c4 1c             	add    $0x1c,%esp
f01016d3:	5b                   	pop    %ebx
f01016d4:	5e                   	pop    %esi
f01016d5:	5f                   	pop    %edi
f01016d6:	5d                   	pop    %ebp
f01016d7:	c3                   	ret    
f01016d8:	90                   	nop
f01016d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01016e0:	39 ce                	cmp    %ecx,%esi
f01016e2:	77 74                	ja     f0101758 <__udivdi3+0xd8>
f01016e4:	0f bd fe             	bsr    %esi,%edi
f01016e7:	83 f7 1f             	xor    $0x1f,%edi
f01016ea:	0f 84 98 00 00 00    	je     f0101788 <__udivdi3+0x108>
f01016f0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01016f5:	89 f9                	mov    %edi,%ecx
f01016f7:	89 c5                	mov    %eax,%ebp
f01016f9:	29 fb                	sub    %edi,%ebx
f01016fb:	d3 e6                	shl    %cl,%esi
f01016fd:	89 d9                	mov    %ebx,%ecx
f01016ff:	d3 ed                	shr    %cl,%ebp
f0101701:	89 f9                	mov    %edi,%ecx
f0101703:	d3 e0                	shl    %cl,%eax
f0101705:	09 ee                	or     %ebp,%esi
f0101707:	89 d9                	mov    %ebx,%ecx
f0101709:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010170d:	89 d5                	mov    %edx,%ebp
f010170f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101713:	d3 ed                	shr    %cl,%ebp
f0101715:	89 f9                	mov    %edi,%ecx
f0101717:	d3 e2                	shl    %cl,%edx
f0101719:	89 d9                	mov    %ebx,%ecx
f010171b:	d3 e8                	shr    %cl,%eax
f010171d:	09 c2                	or     %eax,%edx
f010171f:	89 d0                	mov    %edx,%eax
f0101721:	89 ea                	mov    %ebp,%edx
f0101723:	f7 f6                	div    %esi
f0101725:	89 d5                	mov    %edx,%ebp
f0101727:	89 c3                	mov    %eax,%ebx
f0101729:	f7 64 24 0c          	mull   0xc(%esp)
f010172d:	39 d5                	cmp    %edx,%ebp
f010172f:	72 10                	jb     f0101741 <__udivdi3+0xc1>
f0101731:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101735:	89 f9                	mov    %edi,%ecx
f0101737:	d3 e6                	shl    %cl,%esi
f0101739:	39 c6                	cmp    %eax,%esi
f010173b:	73 07                	jae    f0101744 <__udivdi3+0xc4>
f010173d:	39 d5                	cmp    %edx,%ebp
f010173f:	75 03                	jne    f0101744 <__udivdi3+0xc4>
f0101741:	83 eb 01             	sub    $0x1,%ebx
f0101744:	31 ff                	xor    %edi,%edi
f0101746:	89 d8                	mov    %ebx,%eax
f0101748:	89 fa                	mov    %edi,%edx
f010174a:	83 c4 1c             	add    $0x1c,%esp
f010174d:	5b                   	pop    %ebx
f010174e:	5e                   	pop    %esi
f010174f:	5f                   	pop    %edi
f0101750:	5d                   	pop    %ebp
f0101751:	c3                   	ret    
f0101752:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101758:	31 ff                	xor    %edi,%edi
f010175a:	31 db                	xor    %ebx,%ebx
f010175c:	89 d8                	mov    %ebx,%eax
f010175e:	89 fa                	mov    %edi,%edx
f0101760:	83 c4 1c             	add    $0x1c,%esp
f0101763:	5b                   	pop    %ebx
f0101764:	5e                   	pop    %esi
f0101765:	5f                   	pop    %edi
f0101766:	5d                   	pop    %ebp
f0101767:	c3                   	ret    
f0101768:	90                   	nop
f0101769:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101770:	89 d8                	mov    %ebx,%eax
f0101772:	f7 f7                	div    %edi
f0101774:	31 ff                	xor    %edi,%edi
f0101776:	89 c3                	mov    %eax,%ebx
f0101778:	89 d8                	mov    %ebx,%eax
f010177a:	89 fa                	mov    %edi,%edx
f010177c:	83 c4 1c             	add    $0x1c,%esp
f010177f:	5b                   	pop    %ebx
f0101780:	5e                   	pop    %esi
f0101781:	5f                   	pop    %edi
f0101782:	5d                   	pop    %ebp
f0101783:	c3                   	ret    
f0101784:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101788:	39 ce                	cmp    %ecx,%esi
f010178a:	72 0c                	jb     f0101798 <__udivdi3+0x118>
f010178c:	31 db                	xor    %ebx,%ebx
f010178e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0101792:	0f 87 34 ff ff ff    	ja     f01016cc <__udivdi3+0x4c>
f0101798:	bb 01 00 00 00       	mov    $0x1,%ebx
f010179d:	e9 2a ff ff ff       	jmp    f01016cc <__udivdi3+0x4c>
f01017a2:	66 90                	xchg   %ax,%ax
f01017a4:	66 90                	xchg   %ax,%ax
f01017a6:	66 90                	xchg   %ax,%ax
f01017a8:	66 90                	xchg   %ax,%ax
f01017aa:	66 90                	xchg   %ax,%ax
f01017ac:	66 90                	xchg   %ax,%ax
f01017ae:	66 90                	xchg   %ax,%ax

f01017b0 <__umoddi3>:
f01017b0:	55                   	push   %ebp
f01017b1:	57                   	push   %edi
f01017b2:	56                   	push   %esi
f01017b3:	53                   	push   %ebx
f01017b4:	83 ec 1c             	sub    $0x1c,%esp
f01017b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01017bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01017bf:	8b 74 24 34          	mov    0x34(%esp),%esi
f01017c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01017c7:	85 d2                	test   %edx,%edx
f01017c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01017cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01017d1:	89 f3                	mov    %esi,%ebx
f01017d3:	89 3c 24             	mov    %edi,(%esp)
f01017d6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01017da:	75 1c                	jne    f01017f8 <__umoddi3+0x48>
f01017dc:	39 f7                	cmp    %esi,%edi
f01017de:	76 50                	jbe    f0101830 <__umoddi3+0x80>
f01017e0:	89 c8                	mov    %ecx,%eax
f01017e2:	89 f2                	mov    %esi,%edx
f01017e4:	f7 f7                	div    %edi
f01017e6:	89 d0                	mov    %edx,%eax
f01017e8:	31 d2                	xor    %edx,%edx
f01017ea:	83 c4 1c             	add    $0x1c,%esp
f01017ed:	5b                   	pop    %ebx
f01017ee:	5e                   	pop    %esi
f01017ef:	5f                   	pop    %edi
f01017f0:	5d                   	pop    %ebp
f01017f1:	c3                   	ret    
f01017f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01017f8:	39 f2                	cmp    %esi,%edx
f01017fa:	89 d0                	mov    %edx,%eax
f01017fc:	77 52                	ja     f0101850 <__umoddi3+0xa0>
f01017fe:	0f bd ea             	bsr    %edx,%ebp
f0101801:	83 f5 1f             	xor    $0x1f,%ebp
f0101804:	75 5a                	jne    f0101860 <__umoddi3+0xb0>
f0101806:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010180a:	0f 82 e0 00 00 00    	jb     f01018f0 <__umoddi3+0x140>
f0101810:	39 0c 24             	cmp    %ecx,(%esp)
f0101813:	0f 86 d7 00 00 00    	jbe    f01018f0 <__umoddi3+0x140>
f0101819:	8b 44 24 08          	mov    0x8(%esp),%eax
f010181d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101821:	83 c4 1c             	add    $0x1c,%esp
f0101824:	5b                   	pop    %ebx
f0101825:	5e                   	pop    %esi
f0101826:	5f                   	pop    %edi
f0101827:	5d                   	pop    %ebp
f0101828:	c3                   	ret    
f0101829:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101830:	85 ff                	test   %edi,%edi
f0101832:	89 fd                	mov    %edi,%ebp
f0101834:	75 0b                	jne    f0101841 <__umoddi3+0x91>
f0101836:	b8 01 00 00 00       	mov    $0x1,%eax
f010183b:	31 d2                	xor    %edx,%edx
f010183d:	f7 f7                	div    %edi
f010183f:	89 c5                	mov    %eax,%ebp
f0101841:	89 f0                	mov    %esi,%eax
f0101843:	31 d2                	xor    %edx,%edx
f0101845:	f7 f5                	div    %ebp
f0101847:	89 c8                	mov    %ecx,%eax
f0101849:	f7 f5                	div    %ebp
f010184b:	89 d0                	mov    %edx,%eax
f010184d:	eb 99                	jmp    f01017e8 <__umoddi3+0x38>
f010184f:	90                   	nop
f0101850:	89 c8                	mov    %ecx,%eax
f0101852:	89 f2                	mov    %esi,%edx
f0101854:	83 c4 1c             	add    $0x1c,%esp
f0101857:	5b                   	pop    %ebx
f0101858:	5e                   	pop    %esi
f0101859:	5f                   	pop    %edi
f010185a:	5d                   	pop    %ebp
f010185b:	c3                   	ret    
f010185c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101860:	8b 34 24             	mov    (%esp),%esi
f0101863:	bf 20 00 00 00       	mov    $0x20,%edi
f0101868:	89 e9                	mov    %ebp,%ecx
f010186a:	29 ef                	sub    %ebp,%edi
f010186c:	d3 e0                	shl    %cl,%eax
f010186e:	89 f9                	mov    %edi,%ecx
f0101870:	89 f2                	mov    %esi,%edx
f0101872:	d3 ea                	shr    %cl,%edx
f0101874:	89 e9                	mov    %ebp,%ecx
f0101876:	09 c2                	or     %eax,%edx
f0101878:	89 d8                	mov    %ebx,%eax
f010187a:	89 14 24             	mov    %edx,(%esp)
f010187d:	89 f2                	mov    %esi,%edx
f010187f:	d3 e2                	shl    %cl,%edx
f0101881:	89 f9                	mov    %edi,%ecx
f0101883:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101887:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010188b:	d3 e8                	shr    %cl,%eax
f010188d:	89 e9                	mov    %ebp,%ecx
f010188f:	89 c6                	mov    %eax,%esi
f0101891:	d3 e3                	shl    %cl,%ebx
f0101893:	89 f9                	mov    %edi,%ecx
f0101895:	89 d0                	mov    %edx,%eax
f0101897:	d3 e8                	shr    %cl,%eax
f0101899:	89 e9                	mov    %ebp,%ecx
f010189b:	09 d8                	or     %ebx,%eax
f010189d:	89 d3                	mov    %edx,%ebx
f010189f:	89 f2                	mov    %esi,%edx
f01018a1:	f7 34 24             	divl   (%esp)
f01018a4:	89 d6                	mov    %edx,%esi
f01018a6:	d3 e3                	shl    %cl,%ebx
f01018a8:	f7 64 24 04          	mull   0x4(%esp)
f01018ac:	39 d6                	cmp    %edx,%esi
f01018ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01018b2:	89 d1                	mov    %edx,%ecx
f01018b4:	89 c3                	mov    %eax,%ebx
f01018b6:	72 08                	jb     f01018c0 <__umoddi3+0x110>
f01018b8:	75 11                	jne    f01018cb <__umoddi3+0x11b>
f01018ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01018be:	73 0b                	jae    f01018cb <__umoddi3+0x11b>
f01018c0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01018c4:	1b 14 24             	sbb    (%esp),%edx
f01018c7:	89 d1                	mov    %edx,%ecx
f01018c9:	89 c3                	mov    %eax,%ebx
f01018cb:	8b 54 24 08          	mov    0x8(%esp),%edx
f01018cf:	29 da                	sub    %ebx,%edx
f01018d1:	19 ce                	sbb    %ecx,%esi
f01018d3:	89 f9                	mov    %edi,%ecx
f01018d5:	89 f0                	mov    %esi,%eax
f01018d7:	d3 e0                	shl    %cl,%eax
f01018d9:	89 e9                	mov    %ebp,%ecx
f01018db:	d3 ea                	shr    %cl,%edx
f01018dd:	89 e9                	mov    %ebp,%ecx
f01018df:	d3 ee                	shr    %cl,%esi
f01018e1:	09 d0                	or     %edx,%eax
f01018e3:	89 f2                	mov    %esi,%edx
f01018e5:	83 c4 1c             	add    $0x1c,%esp
f01018e8:	5b                   	pop    %ebx
f01018e9:	5e                   	pop    %esi
f01018ea:	5f                   	pop    %edi
f01018eb:	5d                   	pop    %ebp
f01018ec:	c3                   	ret    
f01018ed:	8d 76 00             	lea    0x0(%esi),%esi
f01018f0:	29 f9                	sub    %edi,%ecx
f01018f2:	19 d6                	sbb    %edx,%esi
f01018f4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01018f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01018fc:	e9 18 ff ff ff       	jmp    f0101819 <__umoddi3+0x69>
