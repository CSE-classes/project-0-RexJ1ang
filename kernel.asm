
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 00 51 11 80       	mov    $0x80115100,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 99 38 10 80       	mov    $0x80103899,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 6c 85 10 80       	push   $0x8010856c
80100042:	68 a0 b5 10 80       	push   $0x8010b5a0
80100047:	e8 d7 4f 00 00       	call   80105023 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 b0 f4 10 80 a4 	movl   $0x8010f4a4,0x8010f4b0
80100056:	f4 10 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 b4 f4 10 80 a4 	movl   $0x8010f4a4,0x8010f4b4
80100060:	f4 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 d4 b5 10 80 	movl   $0x8010b5d4,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 b4 f4 10 80    	mov    0x8010f4b4,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c a4 f4 10 80 	movl   $0x8010f4a4,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 b4 f4 10 80       	mov    0x8010f4b4,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 b4 f4 10 80       	mov    %eax,0x8010f4b4
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 a4 f4 10 80       	mov    $0x8010f4a4,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
  }
}
801000b0:	90                   	nop
801000b1:	90                   	nop
801000b2:	c9                   	leave
801000b3:	c3                   	ret

801000b4 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b4:	55                   	push   %ebp
801000b5:	89 e5                	mov    %esp,%ebp
801000b7:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000ba:	83 ec 0c             	sub    $0xc,%esp
801000bd:	68 a0 b5 10 80       	push   $0x8010b5a0
801000c2:	e8 7e 4f 00 00       	call   80105045 <acquire>
801000c7:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000ca:	a1 b4 f4 10 80       	mov    0x8010f4b4,%eax
801000cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d2:	eb 67                	jmp    8010013b <bget+0x87>
    if(b->dev == dev && b->blockno == blockno){
801000d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d7:	8b 40 04             	mov    0x4(%eax),%eax
801000da:	39 45 08             	cmp    %eax,0x8(%ebp)
801000dd:	75 53                	jne    80100132 <bget+0x7e>
801000df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e2:	8b 40 08             	mov    0x8(%eax),%eax
801000e5:	39 45 0c             	cmp    %eax,0xc(%ebp)
801000e8:	75 48                	jne    80100132 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ed:	8b 00                	mov    (%eax),%eax
801000ef:	83 e0 01             	and    $0x1,%eax
801000f2:	85 c0                	test   %eax,%eax
801000f4:	75 27                	jne    8010011d <bget+0x69>
        b->flags |= B_BUSY;
801000f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f9:	8b 00                	mov    (%eax),%eax
801000fb:	83 c8 01             	or     $0x1,%eax
801000fe:	89 c2                	mov    %eax,%edx
80100100:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100103:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100105:	83 ec 0c             	sub    $0xc,%esp
80100108:	68 a0 b5 10 80       	push   $0x8010b5a0
8010010d:	e8 9a 4f 00 00       	call   801050ac <release>
80100112:	83 c4 10             	add    $0x10,%esp
        return b;
80100115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100118:	e9 98 00 00 00       	jmp    801001b5 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011d:	83 ec 08             	sub    $0x8,%esp
80100120:	68 a0 b5 10 80       	push   $0x8010b5a0
80100125:	ff 75 f4             	push   -0xc(%ebp)
80100128:	e8 1d 4c 00 00       	call   80104d4a <sleep>
8010012d:	83 c4 10             	add    $0x10,%esp
      goto loop;
80100130:	eb 98                	jmp    801000ca <bget+0x16>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100135:	8b 40 10             	mov    0x10(%eax),%eax
80100138:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013b:	81 7d f4 a4 f4 10 80 	cmpl   $0x8010f4a4,-0xc(%ebp)
80100142:	75 90                	jne    801000d4 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100144:	a1 b0 f4 10 80       	mov    0x8010f4b0,%eax
80100149:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014c:	eb 51                	jmp    8010019f <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 01             	and    $0x1,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 3c                	jne    80100196 <bget+0xe2>
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 00                	mov    (%eax),%eax
8010015f:	83 e0 04             	and    $0x4,%eax
80100162:	85 c0                	test   %eax,%eax
80100164:	75 30                	jne    80100196 <bget+0xe2>
      b->dev = dev;
80100166:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100169:	8b 55 08             	mov    0x8(%ebp),%edx
8010016c:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100172:	8b 55 0c             	mov    0xc(%ebp),%edx
80100175:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100178:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100181:	83 ec 0c             	sub    $0xc,%esp
80100184:	68 a0 b5 10 80       	push   $0x8010b5a0
80100189:	e8 1e 4f 00 00       	call   801050ac <release>
8010018e:	83 c4 10             	add    $0x10,%esp
      return b;
80100191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100194:	eb 1f                	jmp    801001b5 <bget+0x101>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100196:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100199:	8b 40 0c             	mov    0xc(%eax),%eax
8010019c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019f:	81 7d f4 a4 f4 10 80 	cmpl   $0x8010f4a4,-0xc(%ebp)
801001a6:	75 a6                	jne    8010014e <bget+0x9a>
    }
  }
  panic("bget: no buffers");
801001a8:	83 ec 0c             	sub    $0xc,%esp
801001ab:	68 73 85 10 80       	push   $0x80108573
801001b0:	e8 c4 03 00 00       	call   80100579 <panic>
}
801001b5:	c9                   	leave
801001b6:	c3                   	ret

801001b7 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b7:	55                   	push   %ebp
801001b8:	89 e5                	mov    %esp,%ebp
801001ba:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bd:	83 ec 08             	sub    $0x8,%esp
801001c0:	ff 75 0c             	push   0xc(%ebp)
801001c3:	ff 75 08             	push   0x8(%ebp)
801001c6:	e8 e9 fe ff ff       	call   801000b4 <bget>
801001cb:	83 c4 10             	add    $0x10,%esp
801001ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	8b 00                	mov    (%eax),%eax
801001d6:	83 e0 02             	and    $0x2,%eax
801001d9:	85 c0                	test   %eax,%eax
801001db:	75 0e                	jne    801001eb <bread+0x34>
    iderw(b);
801001dd:	83 ec 0c             	sub    $0xc,%esp
801001e0:	ff 75 f4             	push   -0xc(%ebp)
801001e3:	e8 37 27 00 00       	call   8010291f <iderw>
801001e8:	83 c4 10             	add    $0x10,%esp
  }
  return b;
801001eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ee:	c9                   	leave
801001ef:	c3                   	ret

801001f0 <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001f0:	55                   	push   %ebp
801001f1:	89 e5                	mov    %esp,%ebp
801001f3:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f6:	8b 45 08             	mov    0x8(%ebp),%eax
801001f9:	8b 00                	mov    (%eax),%eax
801001fb:	83 e0 01             	and    $0x1,%eax
801001fe:	85 c0                	test   %eax,%eax
80100200:	75 0d                	jne    8010020f <bwrite+0x1f>
    panic("bwrite");
80100202:	83 ec 0c             	sub    $0xc,%esp
80100205:	68 84 85 10 80       	push   $0x80108584
8010020a:	e8 6a 03 00 00       	call   80100579 <panic>
  b->flags |= B_DIRTY;
8010020f:	8b 45 08             	mov    0x8(%ebp),%eax
80100212:	8b 00                	mov    (%eax),%eax
80100214:	83 c8 04             	or     $0x4,%eax
80100217:	89 c2                	mov    %eax,%edx
80100219:	8b 45 08             	mov    0x8(%ebp),%eax
8010021c:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021e:	83 ec 0c             	sub    $0xc,%esp
80100221:	ff 75 08             	push   0x8(%ebp)
80100224:	e8 f6 26 00 00       	call   8010291f <iderw>
80100229:	83 c4 10             	add    $0x10,%esp
}
8010022c:	90                   	nop
8010022d:	c9                   	leave
8010022e:	c3                   	ret

8010022f <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022f:	55                   	push   %ebp
80100230:	89 e5                	mov    %esp,%ebp
80100232:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100235:	8b 45 08             	mov    0x8(%ebp),%eax
80100238:	8b 00                	mov    (%eax),%eax
8010023a:	83 e0 01             	and    $0x1,%eax
8010023d:	85 c0                	test   %eax,%eax
8010023f:	75 0d                	jne    8010024e <brelse+0x1f>
    panic("brelse");
80100241:	83 ec 0c             	sub    $0xc,%esp
80100244:	68 8b 85 10 80       	push   $0x8010858b
80100249:	e8 2b 03 00 00       	call   80100579 <panic>

  acquire(&bcache.lock);
8010024e:	83 ec 0c             	sub    $0xc,%esp
80100251:	68 a0 b5 10 80       	push   $0x8010b5a0
80100256:	e8 ea 4d 00 00       	call   80105045 <acquire>
8010025b:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025e:	8b 45 08             	mov    0x8(%ebp),%eax
80100261:	8b 40 10             	mov    0x10(%eax),%eax
80100264:	8b 55 08             	mov    0x8(%ebp),%edx
80100267:	8b 52 0c             	mov    0xc(%edx),%edx
8010026a:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026d:	8b 45 08             	mov    0x8(%ebp),%eax
80100270:	8b 40 0c             	mov    0xc(%eax),%eax
80100273:	8b 55 08             	mov    0x8(%ebp),%edx
80100276:	8b 52 10             	mov    0x10(%edx),%edx
80100279:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027c:	8b 15 b4 f4 10 80    	mov    0x8010f4b4,%edx
80100282:	8b 45 08             	mov    0x8(%ebp),%eax
80100285:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	c7 40 0c a4 f4 10 80 	movl   $0x8010f4a4,0xc(%eax)
  bcache.head.next->prev = b;
80100292:	a1 b4 f4 10 80       	mov    0x8010f4b4,%eax
80100297:	8b 55 08             	mov    0x8(%ebp),%edx
8010029a:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029d:	8b 45 08             	mov    0x8(%ebp),%eax
801002a0:	a3 b4 f4 10 80       	mov    %eax,0x8010f4b4

  b->flags &= ~B_BUSY;
801002a5:	8b 45 08             	mov    0x8(%ebp),%eax
801002a8:	8b 00                	mov    (%eax),%eax
801002aa:	83 e0 fe             	and    $0xfffffffe,%eax
801002ad:	89 c2                	mov    %eax,%edx
801002af:	8b 45 08             	mov    0x8(%ebp),%eax
801002b2:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b4:	83 ec 0c             	sub    $0xc,%esp
801002b7:	ff 75 08             	push   0x8(%ebp)
801002ba:	e8 77 4b 00 00       	call   80104e36 <wakeup>
801002bf:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c2:	83 ec 0c             	sub    $0xc,%esp
801002c5:	68 a0 b5 10 80       	push   $0x8010b5a0
801002ca:	e8 dd 4d 00 00       	call   801050ac <release>
801002cf:	83 c4 10             	add    $0x10,%esp
}
801002d2:	90                   	nop
801002d3:	c9                   	leave
801002d4:	c3                   	ret

801002d5 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d5:	55                   	push   %ebp
801002d6:	89 e5                	mov    %esp,%ebp
801002d8:	83 ec 14             	sub    $0x14,%esp
801002db:	8b 45 08             	mov    0x8(%ebp),%eax
801002de:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e6:	89 c2                	mov    %eax,%edx
801002e8:	ec                   	in     (%dx),%al
801002e9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002ec:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002f0:	c9                   	leave
801002f1:	c3                   	ret

801002f2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f2:	55                   	push   %ebp
801002f3:	89 e5                	mov    %esp,%ebp
801002f5:	83 ec 08             	sub    $0x8,%esp
801002f8:	8b 55 08             	mov    0x8(%ebp),%edx
801002fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801002fe:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100302:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100305:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100309:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030d:	ee                   	out    %al,(%dx)
}
8010030e:	90                   	nop
8010030f:	c9                   	leave
80100310:	c3                   	ret

80100311 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100311:	55                   	push   %ebp
80100312:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100314:	fa                   	cli
}
80100315:	90                   	nop
80100316:	5d                   	pop    %ebp
80100317:	c3                   	ret

80100318 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100318:	55                   	push   %ebp
80100319:	89 e5                	mov    %esp,%ebp
8010031b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100322:	74 1c                	je     80100340 <printint+0x28>
80100324:	8b 45 08             	mov    0x8(%ebp),%eax
80100327:	c1 e8 1f             	shr    $0x1f,%eax
8010032a:	0f b6 c0             	movzbl %al,%eax
8010032d:	89 45 10             	mov    %eax,0x10(%ebp)
80100330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100334:	74 0a                	je     80100340 <printint+0x28>
    x = -xx;
80100336:	8b 45 08             	mov    0x8(%ebp),%eax
80100339:	f7 d8                	neg    %eax
8010033b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033e:	eb 06                	jmp    80100346 <printint+0x2e>
  else
    x = xx;
80100340:	8b 45 08             	mov    0x8(%ebp),%eax
80100343:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100350:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100353:	ba 00 00 00 00       	mov    $0x0,%edx
80100358:	f7 f1                	div    %ecx
8010035a:	89 d1                	mov    %edx,%ecx
8010035c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010035f:	8d 50 01             	lea    0x1(%eax),%edx
80100362:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100365:	0f b6 91 04 90 10 80 	movzbl -0x7fef6ffc(%ecx),%edx
8010036c:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
80100370:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100376:	ba 00 00 00 00       	mov    $0x0,%edx
8010037b:	f7 f1                	div    %ecx
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100384:	75 c7                	jne    8010034d <printint+0x35>

  if(sign)
80100386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038a:	74 2a                	je     801003b6 <printint+0x9e>
    buf[i++] = '-';
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039a:	eb 1a                	jmp    801003b6 <printint+0x9e>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	0f b6 00             	movzbl (%eax),%eax
801003a7:	0f be c0             	movsbl %al,%eax
801003aa:	83 ec 0c             	sub    $0xc,%esp
801003ad:	50                   	push   %eax
801003ae:	e8 fb 03 00 00       	call   801007ae <consputc>
801003b3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003be:	79 dc                	jns    8010039c <printint+0x84>
}
801003c0:	90                   	nop
801003c1:	90                   	nop
801003c2:	c9                   	leave
801003c3:	c3                   	ret

801003c4 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c4:	55                   	push   %ebp
801003c5:	89 e5                	mov    %esp,%ebp
801003c7:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003ca:	a1 94 f7 10 80       	mov    0x8010f794,%eax
801003cf:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d6:	74 10                	je     801003e8 <cprintf+0x24>
    acquire(&cons.lock);
801003d8:	83 ec 0c             	sub    $0xc,%esp
801003db:	68 60 f7 10 80       	push   $0x8010f760
801003e0:	e8 60 4c 00 00       	call   80105045 <acquire>
801003e5:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003e8:	8b 45 08             	mov    0x8(%ebp),%eax
801003eb:	85 c0                	test   %eax,%eax
801003ed:	75 0d                	jne    801003fc <cprintf+0x38>
    panic("null fmt");
801003ef:	83 ec 0c             	sub    $0xc,%esp
801003f2:	68 92 85 10 80       	push   $0x80108592
801003f7:	e8 7d 01 00 00       	call   80100579 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fc:	8d 45 0c             	lea    0xc(%ebp),%eax
801003ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100402:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100409:	e9 2f 01 00 00       	jmp    8010053d <cprintf+0x179>
    if(c != '%'){
8010040e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100412:	74 13                	je     80100427 <cprintf+0x63>
      consputc(c);
80100414:	83 ec 0c             	sub    $0xc,%esp
80100417:	ff 75 e4             	push   -0x1c(%ebp)
8010041a:	e8 8f 03 00 00       	call   801007ae <consputc>
8010041f:	83 c4 10             	add    $0x10,%esp
      continue;
80100422:	e9 12 01 00 00       	jmp    80100539 <cprintf+0x175>
    }
    c = fmt[++i] & 0xff;
80100427:	8b 55 08             	mov    0x8(%ebp),%edx
8010042a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010042e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100431:	01 d0                	add    %edx,%eax
80100433:	0f b6 00             	movzbl (%eax),%eax
80100436:	0f be c0             	movsbl %al,%eax
80100439:	25 ff 00 00 00       	and    $0xff,%eax
8010043e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100441:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100445:	0f 84 14 01 00 00    	je     8010055f <cprintf+0x19b>
      break;
    switch(c){
8010044b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010044f:	74 5e                	je     801004af <cprintf+0xeb>
80100451:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100455:	0f 8f c2 00 00 00    	jg     8010051d <cprintf+0x159>
8010045b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
8010045f:	74 6b                	je     801004cc <cprintf+0x108>
80100461:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
80100465:	0f 8f b2 00 00 00    	jg     8010051d <cprintf+0x159>
8010046b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
8010046f:	74 3e                	je     801004af <cprintf+0xeb>
80100471:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
80100475:	0f 8f a2 00 00 00    	jg     8010051d <cprintf+0x159>
8010047b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010047f:	0f 84 89 00 00 00    	je     8010050e <cprintf+0x14a>
80100485:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
80100489:	0f 85 8e 00 00 00    	jne    8010051d <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
8010048f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100492:	8d 50 04             	lea    0x4(%eax),%edx
80100495:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100498:	8b 00                	mov    (%eax),%eax
8010049a:	83 ec 04             	sub    $0x4,%esp
8010049d:	6a 01                	push   $0x1
8010049f:	6a 0a                	push   $0xa
801004a1:	50                   	push   %eax
801004a2:	e8 71 fe ff ff       	call   80100318 <printint>
801004a7:	83 c4 10             	add    $0x10,%esp
      break;
801004aa:	e9 8a 00 00 00       	jmp    80100539 <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004b2:	8d 50 04             	lea    0x4(%eax),%edx
801004b5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004b8:	8b 00                	mov    (%eax),%eax
801004ba:	83 ec 04             	sub    $0x4,%esp
801004bd:	6a 00                	push   $0x0
801004bf:	6a 10                	push   $0x10
801004c1:	50                   	push   %eax
801004c2:	e8 51 fe ff ff       	call   80100318 <printint>
801004c7:	83 c4 10             	add    $0x10,%esp
      break;
801004ca:	eb 6d                	jmp    80100539 <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
801004cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004cf:	8d 50 04             	lea    0x4(%eax),%edx
801004d2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004d5:	8b 00                	mov    (%eax),%eax
801004d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004da:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004de:	75 22                	jne    80100502 <cprintf+0x13e>
        s = "(null)";
801004e0:	c7 45 ec 9b 85 10 80 	movl   $0x8010859b,-0x14(%ebp)
      for(; *s; s++)
801004e7:	eb 19                	jmp    80100502 <cprintf+0x13e>
        consputc(*s);
801004e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004ec:	0f b6 00             	movzbl (%eax),%eax
801004ef:	0f be c0             	movsbl %al,%eax
801004f2:	83 ec 0c             	sub    $0xc,%esp
801004f5:	50                   	push   %eax
801004f6:	e8 b3 02 00 00       	call   801007ae <consputc>
801004fb:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
801004fe:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100502:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100505:	0f b6 00             	movzbl (%eax),%eax
80100508:	84 c0                	test   %al,%al
8010050a:	75 dd                	jne    801004e9 <cprintf+0x125>
      break;
8010050c:	eb 2b                	jmp    80100539 <cprintf+0x175>
    case '%':
      consputc('%');
8010050e:	83 ec 0c             	sub    $0xc,%esp
80100511:	6a 25                	push   $0x25
80100513:	e8 96 02 00 00       	call   801007ae <consputc>
80100518:	83 c4 10             	add    $0x10,%esp
      break;
8010051b:	eb 1c                	jmp    80100539 <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010051d:	83 ec 0c             	sub    $0xc,%esp
80100520:	6a 25                	push   $0x25
80100522:	e8 87 02 00 00       	call   801007ae <consputc>
80100527:	83 c4 10             	add    $0x10,%esp
      consputc(c);
8010052a:	83 ec 0c             	sub    $0xc,%esp
8010052d:	ff 75 e4             	push   -0x1c(%ebp)
80100530:	e8 79 02 00 00       	call   801007ae <consputc>
80100535:	83 c4 10             	add    $0x10,%esp
      break;
80100538:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100539:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010053d:	8b 55 08             	mov    0x8(%ebp),%edx
80100540:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100543:	01 d0                	add    %edx,%eax
80100545:	0f b6 00             	movzbl (%eax),%eax
80100548:	0f be c0             	movsbl %al,%eax
8010054b:	25 ff 00 00 00       	and    $0xff,%eax
80100550:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100553:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100557:	0f 85 b1 fe ff ff    	jne    8010040e <cprintf+0x4a>
8010055d:	eb 01                	jmp    80100560 <cprintf+0x19c>
      break;
8010055f:	90                   	nop
    }
  }

  if(locking)
80100560:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100564:	74 10                	je     80100576 <cprintf+0x1b2>
    release(&cons.lock);
80100566:	83 ec 0c             	sub    $0xc,%esp
80100569:	68 60 f7 10 80       	push   $0x8010f760
8010056e:	e8 39 4b 00 00       	call   801050ac <release>
80100573:	83 c4 10             	add    $0x10,%esp
}
80100576:	90                   	nop
80100577:	c9                   	leave
80100578:	c3                   	ret

80100579 <panic>:

void
panic(char *s)
{
80100579:	55                   	push   %ebp
8010057a:	89 e5                	mov    %esp,%ebp
8010057c:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
8010057f:	e8 8d fd ff ff       	call   80100311 <cli>
  cons.locking = 0;
80100584:	c7 05 94 f7 10 80 00 	movl   $0x0,0x8010f794
8010058b:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010058e:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100594:	0f b6 00             	movzbl (%eax),%eax
80100597:	0f b6 c0             	movzbl %al,%eax
8010059a:	83 ec 08             	sub    $0x8,%esp
8010059d:	50                   	push   %eax
8010059e:	68 a2 85 10 80       	push   $0x801085a2
801005a3:	e8 1c fe ff ff       	call   801003c4 <cprintf>
801005a8:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005ab:	8b 45 08             	mov    0x8(%ebp),%eax
801005ae:	83 ec 0c             	sub    $0xc,%esp
801005b1:	50                   	push   %eax
801005b2:	e8 0d fe ff ff       	call   801003c4 <cprintf>
801005b7:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005ba:	83 ec 0c             	sub    $0xc,%esp
801005bd:	68 b1 85 10 80       	push   $0x801085b1
801005c2:	e8 fd fd ff ff       	call   801003c4 <cprintf>
801005c7:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005ca:	83 ec 08             	sub    $0x8,%esp
801005cd:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005d0:	50                   	push   %eax
801005d1:	8d 45 08             	lea    0x8(%ebp),%eax
801005d4:	50                   	push   %eax
801005d5:	e8 24 4b 00 00       	call   801050fe <getcallerpcs>
801005da:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005e4:	eb 1c                	jmp    80100602 <panic+0x89>
    cprintf(" %p", pcs[i]);
801005e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005e9:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005ed:	83 ec 08             	sub    $0x8,%esp
801005f0:	50                   	push   %eax
801005f1:	68 b3 85 10 80       	push   $0x801085b3
801005f6:	e8 c9 fd ff ff       	call   801003c4 <cprintf>
801005fb:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100602:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80100606:	7e de                	jle    801005e6 <panic+0x6d>
  panicked = 1; // freeze other CPU
80100608:	c7 05 4c f7 10 80 01 	movl   $0x1,0x8010f74c
8010060f:	00 00 00 
  for(;;)
80100612:	90                   	nop
80100613:	eb fd                	jmp    80100612 <panic+0x99>

80100615 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100615:	55                   	push   %ebp
80100616:	89 e5                	mov    %esp,%ebp
80100618:	53                   	push   %ebx
80100619:	83 ec 14             	sub    $0x14,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
8010061c:	6a 0e                	push   $0xe
8010061e:	68 d4 03 00 00       	push   $0x3d4
80100623:	e8 ca fc ff ff       	call   801002f2 <outb>
80100628:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
8010062b:	68 d5 03 00 00       	push   $0x3d5
80100630:	e8 a0 fc ff ff       	call   801002d5 <inb>
80100635:	83 c4 04             	add    $0x4,%esp
80100638:	0f b6 c0             	movzbl %al,%eax
8010063b:	c1 e0 08             	shl    $0x8,%eax
8010063e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
80100641:	6a 0f                	push   $0xf
80100643:	68 d4 03 00 00       	push   $0x3d4
80100648:	e8 a5 fc ff ff       	call   801002f2 <outb>
8010064d:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
80100650:	68 d5 03 00 00       	push   $0x3d5
80100655:	e8 7b fc ff ff       	call   801002d5 <inb>
8010065a:	83 c4 04             	add    $0x4,%esp
8010065d:	0f b6 c0             	movzbl %al,%eax
80100660:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100663:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100667:	75 30                	jne    80100699 <cgaputc+0x84>
    pos += 80 - pos%80;
80100669:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010066c:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100671:	89 c8                	mov    %ecx,%eax
80100673:	f7 ea                	imul   %edx
80100675:	c1 fa 05             	sar    $0x5,%edx
80100678:	89 c8                	mov    %ecx,%eax
8010067a:	c1 f8 1f             	sar    $0x1f,%eax
8010067d:	29 c2                	sub    %eax,%edx
8010067f:	89 d0                	mov    %edx,%eax
80100681:	c1 e0 02             	shl    $0x2,%eax
80100684:	01 d0                	add    %edx,%eax
80100686:	c1 e0 04             	shl    $0x4,%eax
80100689:	29 c1                	sub    %eax,%ecx
8010068b:	89 ca                	mov    %ecx,%edx
8010068d:	b8 50 00 00 00       	mov    $0x50,%eax
80100692:	29 d0                	sub    %edx,%eax
80100694:	01 45 f4             	add    %eax,-0xc(%ebp)
80100697:	eb 38                	jmp    801006d1 <cgaputc+0xbc>
  else if(c == BACKSPACE){
80100699:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006a0:	75 0c                	jne    801006ae <cgaputc+0x99>
    if(pos > 0) --pos;
801006a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006a6:	7e 29                	jle    801006d1 <cgaputc+0xbc>
801006a8:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801006ac:	eb 23                	jmp    801006d1 <cgaputc+0xbc>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
801006ae:	8b 45 08             	mov    0x8(%ebp),%eax
801006b1:	0f b6 c0             	movzbl %al,%eax
801006b4:	80 cc 07             	or     $0x7,%ah
801006b7:	89 c3                	mov    %eax,%ebx
801006b9:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
801006bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006c2:	8d 50 01             	lea    0x1(%eax),%edx
801006c5:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006c8:	01 c0                	add    %eax,%eax
801006ca:	01 c8                	add    %ecx,%eax
801006cc:	89 da                	mov    %ebx,%edx
801006ce:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
801006d1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006d5:	78 09                	js     801006e0 <cgaputc+0xcb>
801006d7:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
801006de:	7e 0d                	jle    801006ed <cgaputc+0xd8>
    panic("pos under/overflow");
801006e0:	83 ec 0c             	sub    $0xc,%esp
801006e3:	68 b7 85 10 80       	push   $0x801085b7
801006e8:	e8 8c fe ff ff       	call   80100579 <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006ed:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006f4:	7e 4c                	jle    80100742 <cgaputc+0x12d>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006f6:	a1 00 90 10 80       	mov    0x80109000,%eax
801006fb:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100701:	a1 00 90 10 80       	mov    0x80109000,%eax
80100706:	83 ec 04             	sub    $0x4,%esp
80100709:	68 60 0e 00 00       	push   $0xe60
8010070e:	52                   	push   %edx
8010070f:	50                   	push   %eax
80100710:	e8 53 4c 00 00       	call   80105368 <memmove>
80100715:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
80100718:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
8010071c:	b8 80 07 00 00       	mov    $0x780,%eax
80100721:	2b 45 f4             	sub    -0xc(%ebp),%eax
80100724:	8d 14 00             	lea    (%eax,%eax,1),%edx
80100727:	a1 00 90 10 80       	mov    0x80109000,%eax
8010072c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010072f:	01 c9                	add    %ecx,%ecx
80100731:	01 c8                	add    %ecx,%eax
80100733:	83 ec 04             	sub    $0x4,%esp
80100736:	52                   	push   %edx
80100737:	6a 00                	push   $0x0
80100739:	50                   	push   %eax
8010073a:	e8 6a 4b 00 00       	call   801052a9 <memset>
8010073f:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
80100742:	83 ec 08             	sub    $0x8,%esp
80100745:	6a 0e                	push   $0xe
80100747:	68 d4 03 00 00       	push   $0x3d4
8010074c:	e8 a1 fb ff ff       	call   801002f2 <outb>
80100751:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
80100754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100757:	c1 f8 08             	sar    $0x8,%eax
8010075a:	0f b6 c0             	movzbl %al,%eax
8010075d:	83 ec 08             	sub    $0x8,%esp
80100760:	50                   	push   %eax
80100761:	68 d5 03 00 00       	push   $0x3d5
80100766:	e8 87 fb ff ff       	call   801002f2 <outb>
8010076b:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
8010076e:	83 ec 08             	sub    $0x8,%esp
80100771:	6a 0f                	push   $0xf
80100773:	68 d4 03 00 00       	push   $0x3d4
80100778:	e8 75 fb ff ff       	call   801002f2 <outb>
8010077d:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
80100780:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100783:	0f b6 c0             	movzbl %al,%eax
80100786:	83 ec 08             	sub    $0x8,%esp
80100789:	50                   	push   %eax
8010078a:	68 d5 03 00 00       	push   $0x3d5
8010078f:	e8 5e fb ff ff       	call   801002f2 <outb>
80100794:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
80100797:	a1 00 90 10 80       	mov    0x80109000,%eax
8010079c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010079f:	01 d2                	add    %edx,%edx
801007a1:	01 d0                	add    %edx,%eax
801007a3:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
801007a8:	90                   	nop
801007a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801007ac:	c9                   	leave
801007ad:	c3                   	ret

801007ae <consputc>:

void
consputc(int c)
{
801007ae:	55                   	push   %ebp
801007af:	89 e5                	mov    %esp,%ebp
801007b1:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
801007b4:	a1 4c f7 10 80       	mov    0x8010f74c,%eax
801007b9:	85 c0                	test   %eax,%eax
801007bb:	74 08                	je     801007c5 <consputc+0x17>
    cli();
801007bd:	e8 4f fb ff ff       	call   80100311 <cli>
    for(;;)
801007c2:	90                   	nop
801007c3:	eb fd                	jmp    801007c2 <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
801007c5:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007cc:	75 29                	jne    801007f7 <consputc+0x49>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007ce:	83 ec 0c             	sub    $0xc,%esp
801007d1:	6a 08                	push   $0x8
801007d3:	e8 1d 64 00 00       	call   80106bf5 <uartputc>
801007d8:	83 c4 10             	add    $0x10,%esp
801007db:	83 ec 0c             	sub    $0xc,%esp
801007de:	6a 20                	push   $0x20
801007e0:	e8 10 64 00 00       	call   80106bf5 <uartputc>
801007e5:	83 c4 10             	add    $0x10,%esp
801007e8:	83 ec 0c             	sub    $0xc,%esp
801007eb:	6a 08                	push   $0x8
801007ed:	e8 03 64 00 00       	call   80106bf5 <uartputc>
801007f2:	83 c4 10             	add    $0x10,%esp
801007f5:	eb 0e                	jmp    80100805 <consputc+0x57>
  } else
    uartputc(c);
801007f7:	83 ec 0c             	sub    $0xc,%esp
801007fa:	ff 75 08             	push   0x8(%ebp)
801007fd:	e8 f3 63 00 00       	call   80106bf5 <uartputc>
80100802:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
80100805:	83 ec 0c             	sub    $0xc,%esp
80100808:	ff 75 08             	push   0x8(%ebp)
8010080b:	e8 05 fe ff ff       	call   80100615 <cgaputc>
80100810:	83 c4 10             	add    $0x10,%esp
}
80100813:	90                   	nop
80100814:	c9                   	leave
80100815:	c3                   	ret

80100816 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
80100816:	55                   	push   %ebp
80100817:	89 e5                	mov    %esp,%ebp
80100819:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
8010081c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
80100823:	83 ec 0c             	sub    $0xc,%esp
80100826:	68 60 f7 10 80       	push   $0x8010f760
8010082b:	e8 15 48 00 00       	call   80105045 <acquire>
80100830:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100833:	e9 58 01 00 00       	jmp    80100990 <consoleintr+0x17a>
    switch(c){
80100838:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010083c:	0f 84 81 00 00 00    	je     801008c3 <consoleintr+0xad>
80100842:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100846:	0f 8f ac 00 00 00    	jg     801008f8 <consoleintr+0xe2>
8010084c:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100850:	74 43                	je     80100895 <consoleintr+0x7f>
80100852:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100856:	0f 8f 9c 00 00 00    	jg     801008f8 <consoleintr+0xe2>
8010085c:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100860:	74 61                	je     801008c3 <consoleintr+0xad>
80100862:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100866:	0f 85 8c 00 00 00    	jne    801008f8 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
8010086c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100873:	e9 18 01 00 00       	jmp    80100990 <consoleintr+0x17a>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100878:	a1 48 f7 10 80       	mov    0x8010f748,%eax
8010087d:	83 e8 01             	sub    $0x1,%eax
80100880:	a3 48 f7 10 80       	mov    %eax,0x8010f748
        consputc(BACKSPACE);
80100885:	83 ec 0c             	sub    $0xc,%esp
80100888:	68 00 01 00 00       	push   $0x100
8010088d:	e8 1c ff ff ff       	call   801007ae <consputc>
80100892:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100895:	8b 15 48 f7 10 80    	mov    0x8010f748,%edx
8010089b:	a1 44 f7 10 80       	mov    0x8010f744,%eax
801008a0:	39 c2                	cmp    %eax,%edx
801008a2:	0f 84 e1 00 00 00    	je     80100989 <consoleintr+0x173>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008a8:	a1 48 f7 10 80       	mov    0x8010f748,%eax
801008ad:	83 e8 01             	sub    $0x1,%eax
801008b0:	83 e0 7f             	and    $0x7f,%eax
801008b3:	0f b6 80 c0 f6 10 80 	movzbl -0x7fef0940(%eax),%eax
      while(input.e != input.w &&
801008ba:	3c 0a                	cmp    $0xa,%al
801008bc:	75 ba                	jne    80100878 <consoleintr+0x62>
      }
      break;
801008be:	e9 c6 00 00 00       	jmp    80100989 <consoleintr+0x173>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008c3:	8b 15 48 f7 10 80    	mov    0x8010f748,%edx
801008c9:	a1 44 f7 10 80       	mov    0x8010f744,%eax
801008ce:	39 c2                	cmp    %eax,%edx
801008d0:	0f 84 b6 00 00 00    	je     8010098c <consoleintr+0x176>
        input.e--;
801008d6:	a1 48 f7 10 80       	mov    0x8010f748,%eax
801008db:	83 e8 01             	sub    $0x1,%eax
801008de:	a3 48 f7 10 80       	mov    %eax,0x8010f748
        consputc(BACKSPACE);
801008e3:	83 ec 0c             	sub    $0xc,%esp
801008e6:	68 00 01 00 00       	push   $0x100
801008eb:	e8 be fe ff ff       	call   801007ae <consputc>
801008f0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008f3:	e9 94 00 00 00       	jmp    8010098c <consoleintr+0x176>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008f8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008fc:	0f 84 8d 00 00 00    	je     8010098f <consoleintr+0x179>
80100902:	8b 15 48 f7 10 80    	mov    0x8010f748,%edx
80100908:	a1 40 f7 10 80       	mov    0x8010f740,%eax
8010090d:	29 c2                	sub    %eax,%edx
8010090f:	83 fa 7f             	cmp    $0x7f,%edx
80100912:	77 7b                	ja     8010098f <consoleintr+0x179>
        c = (c == '\r') ? '\n' : c;
80100914:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80100918:	74 05                	je     8010091f <consoleintr+0x109>
8010091a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010091d:	eb 05                	jmp    80100924 <consoleintr+0x10e>
8010091f:	b8 0a 00 00 00       	mov    $0xa,%eax
80100924:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
80100927:	a1 48 f7 10 80       	mov    0x8010f748,%eax
8010092c:	8d 50 01             	lea    0x1(%eax),%edx
8010092f:	89 15 48 f7 10 80    	mov    %edx,0x8010f748
80100935:	83 e0 7f             	and    $0x7f,%eax
80100938:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010093b:	88 90 c0 f6 10 80    	mov    %dl,-0x7fef0940(%eax)
        consputc(c);
80100941:	83 ec 0c             	sub    $0xc,%esp
80100944:	ff 75 f0             	push   -0x10(%ebp)
80100947:	e8 62 fe ff ff       	call   801007ae <consputc>
8010094c:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010094f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100953:	74 18                	je     8010096d <consoleintr+0x157>
80100955:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100959:	74 12                	je     8010096d <consoleintr+0x157>
8010095b:	8b 15 48 f7 10 80    	mov    0x8010f748,%edx
80100961:	a1 40 f7 10 80       	mov    0x8010f740,%eax
80100966:	83 e8 80             	sub    $0xffffff80,%eax
80100969:	39 c2                	cmp    %eax,%edx
8010096b:	75 22                	jne    8010098f <consoleintr+0x179>
          input.w = input.e;
8010096d:	a1 48 f7 10 80       	mov    0x8010f748,%eax
80100972:	a3 44 f7 10 80       	mov    %eax,0x8010f744
          wakeup(&input.r);
80100977:	83 ec 0c             	sub    $0xc,%esp
8010097a:	68 40 f7 10 80       	push   $0x8010f740
8010097f:	e8 b2 44 00 00       	call   80104e36 <wakeup>
80100984:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100987:	eb 06                	jmp    8010098f <consoleintr+0x179>
      break;
80100989:	90                   	nop
8010098a:	eb 04                	jmp    80100990 <consoleintr+0x17a>
      break;
8010098c:	90                   	nop
8010098d:	eb 01                	jmp    80100990 <consoleintr+0x17a>
      break;
8010098f:	90                   	nop
  while((c = getc()) >= 0){
80100990:	8b 45 08             	mov    0x8(%ebp),%eax
80100993:	ff d0                	call   *%eax
80100995:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100998:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010099c:	0f 89 96 fe ff ff    	jns    80100838 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
801009a2:	83 ec 0c             	sub    $0xc,%esp
801009a5:	68 60 f7 10 80       	push   $0x8010f760
801009aa:	e8 fd 46 00 00       	call   801050ac <release>
801009af:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009b6:	74 05                	je     801009bd <consoleintr+0x1a7>
    procdump();  // now call procdump() wo. cons.lock held
801009b8:	e8 34 45 00 00       	call   80104ef1 <procdump>
  }
}
801009bd:	90                   	nop
801009be:	c9                   	leave
801009bf:	c3                   	ret

801009c0 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
801009c0:	55                   	push   %ebp
801009c1:	89 e5                	mov    %esp,%ebp
801009c3:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
801009c6:	83 ec 0c             	sub    $0xc,%esp
801009c9:	ff 75 08             	push   0x8(%ebp)
801009cc:	e8 16 11 00 00       	call   80101ae7 <iunlock>
801009d1:	83 c4 10             	add    $0x10,%esp
  target = n;
801009d4:	8b 45 10             	mov    0x10(%ebp),%eax
801009d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009da:	83 ec 0c             	sub    $0xc,%esp
801009dd:	68 60 f7 10 80       	push   $0x8010f760
801009e2:	e8 5e 46 00 00       	call   80105045 <acquire>
801009e7:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009ea:	e9 ac 00 00 00       	jmp    80100a9b <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
801009ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801009f5:	8b 40 24             	mov    0x24(%eax),%eax
801009f8:	85 c0                	test   %eax,%eax
801009fa:	74 28                	je     80100a24 <consoleread+0x64>
        release(&cons.lock);
801009fc:	83 ec 0c             	sub    $0xc,%esp
801009ff:	68 60 f7 10 80       	push   $0x8010f760
80100a04:	e8 a3 46 00 00       	call   801050ac <release>
80100a09:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a0c:	83 ec 0c             	sub    $0xc,%esp
80100a0f:	ff 75 08             	push   0x8(%ebp)
80100a12:	e8 72 0f 00 00       	call   80101989 <ilock>
80100a17:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a1a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a1f:	e9 ab 00 00 00       	jmp    80100acf <consoleread+0x10f>
      }
      sleep(&input.r, &cons.lock);
80100a24:	83 ec 08             	sub    $0x8,%esp
80100a27:	68 60 f7 10 80       	push   $0x8010f760
80100a2c:	68 40 f7 10 80       	push   $0x8010f740
80100a31:	e8 14 43 00 00       	call   80104d4a <sleep>
80100a36:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a39:	8b 15 40 f7 10 80    	mov    0x8010f740,%edx
80100a3f:	a1 44 f7 10 80       	mov    0x8010f744,%eax
80100a44:	39 c2                	cmp    %eax,%edx
80100a46:	74 a7                	je     801009ef <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a48:	a1 40 f7 10 80       	mov    0x8010f740,%eax
80100a4d:	8d 50 01             	lea    0x1(%eax),%edx
80100a50:	89 15 40 f7 10 80    	mov    %edx,0x8010f740
80100a56:	83 e0 7f             	and    $0x7f,%eax
80100a59:	0f b6 80 c0 f6 10 80 	movzbl -0x7fef0940(%eax),%eax
80100a60:	0f be c0             	movsbl %al,%eax
80100a63:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a66:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a6a:	75 17                	jne    80100a83 <consoleread+0xc3>
      if(n < target){
80100a6c:	8b 45 10             	mov    0x10(%ebp),%eax
80100a6f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a72:	73 2f                	jae    80100aa3 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a74:	a1 40 f7 10 80       	mov    0x8010f740,%eax
80100a79:	83 e8 01             	sub    $0x1,%eax
80100a7c:	a3 40 f7 10 80       	mov    %eax,0x8010f740
      }
      break;
80100a81:	eb 20                	jmp    80100aa3 <consoleread+0xe3>
    }
    *dst++ = c;
80100a83:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a86:	8d 50 01             	lea    0x1(%eax),%edx
80100a89:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a8c:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a8f:	88 10                	mov    %dl,(%eax)
    --n;
80100a91:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a95:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a99:	74 0b                	je     80100aa6 <consoleread+0xe6>
  while(n > 0){
80100a9b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a9f:	7f 98                	jg     80100a39 <consoleread+0x79>
80100aa1:	eb 04                	jmp    80100aa7 <consoleread+0xe7>
      break;
80100aa3:	90                   	nop
80100aa4:	eb 01                	jmp    80100aa7 <consoleread+0xe7>
      break;
80100aa6:	90                   	nop
  }
  release(&cons.lock);
80100aa7:	83 ec 0c             	sub    $0xc,%esp
80100aaa:	68 60 f7 10 80       	push   $0x8010f760
80100aaf:	e8 f8 45 00 00       	call   801050ac <release>
80100ab4:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ab7:	83 ec 0c             	sub    $0xc,%esp
80100aba:	ff 75 08             	push   0x8(%ebp)
80100abd:	e8 c7 0e 00 00       	call   80101989 <ilock>
80100ac2:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100ac5:	8b 45 10             	mov    0x10(%ebp),%eax
80100ac8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100acb:	29 c2                	sub    %eax,%edx
80100acd:	89 d0                	mov    %edx,%eax
}
80100acf:	c9                   	leave
80100ad0:	c3                   	ret

80100ad1 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100ad1:	55                   	push   %ebp
80100ad2:	89 e5                	mov    %esp,%ebp
80100ad4:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100ad7:	83 ec 0c             	sub    $0xc,%esp
80100ada:	ff 75 08             	push   0x8(%ebp)
80100add:	e8 05 10 00 00       	call   80101ae7 <iunlock>
80100ae2:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ae5:	83 ec 0c             	sub    $0xc,%esp
80100ae8:	68 60 f7 10 80       	push   $0x8010f760
80100aed:	e8 53 45 00 00       	call   80105045 <acquire>
80100af2:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100af5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100afc:	eb 21                	jmp    80100b1f <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100afe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b01:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b04:	01 d0                	add    %edx,%eax
80100b06:	0f b6 00             	movzbl (%eax),%eax
80100b09:	0f be c0             	movsbl %al,%eax
80100b0c:	0f b6 c0             	movzbl %al,%eax
80100b0f:	83 ec 0c             	sub    $0xc,%esp
80100b12:	50                   	push   %eax
80100b13:	e8 96 fc ff ff       	call   801007ae <consputc>
80100b18:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b1b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b22:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b25:	7c d7                	jl     80100afe <consolewrite+0x2d>
  release(&cons.lock);
80100b27:	83 ec 0c             	sub    $0xc,%esp
80100b2a:	68 60 f7 10 80       	push   $0x8010f760
80100b2f:	e8 78 45 00 00       	call   801050ac <release>
80100b34:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b37:	83 ec 0c             	sub    $0xc,%esp
80100b3a:	ff 75 08             	push   0x8(%ebp)
80100b3d:	e8 47 0e 00 00       	call   80101989 <ilock>
80100b42:	83 c4 10             	add    $0x10,%esp

  return n;
80100b45:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b48:	c9                   	leave
80100b49:	c3                   	ret

80100b4a <consoleinit>:

void
consoleinit(void)
{
80100b4a:	55                   	push   %ebp
80100b4b:	89 e5                	mov    %esp,%ebp
80100b4d:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100b50:	83 ec 08             	sub    $0x8,%esp
80100b53:	68 ca 85 10 80       	push   $0x801085ca
80100b58:	68 60 f7 10 80       	push   $0x8010f760
80100b5d:	e8 c1 44 00 00       	call   80105023 <initlock>
80100b62:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b65:	c7 05 ac f7 10 80 d1 	movl   $0x80100ad1,0x8010f7ac
80100b6c:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b6f:	c7 05 a8 f7 10 80 c0 	movl   $0x801009c0,0x8010f7a8
80100b76:	09 10 80 
  cons.locking = 1;
80100b79:	c7 05 94 f7 10 80 01 	movl   $0x1,0x8010f794
80100b80:	00 00 00 

  picenable(IRQ_KBD);
80100b83:	83 ec 0c             	sub    $0xc,%esp
80100b86:	6a 01                	push   $0x1
80100b88:	e8 c1 33 00 00       	call   80103f4e <picenable>
80100b8d:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b90:	83 ec 08             	sub    $0x8,%esp
80100b93:	6a 00                	push   $0x0
80100b95:	6a 01                	push   $0x1
80100b97:	e8 50 1f 00 00       	call   80102aec <ioapicenable>
80100b9c:	83 c4 10             	add    $0x10,%esp
}
80100b9f:	90                   	nop
80100ba0:	c9                   	leave
80100ba1:	c3                   	ret

80100ba2 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100ba2:	55                   	push   %ebp
80100ba3:	89 e5                	mov    %esp,%ebp
80100ba5:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100bab:	e8 a6 29 00 00       	call   80103556 <begin_op>
  if((ip = namei(path)) == 0){
80100bb0:	83 ec 0c             	sub    $0xc,%esp
80100bb3:	ff 75 08             	push   0x8(%ebp)
80100bb6:	e8 7f 19 00 00       	call   8010253a <namei>
80100bbb:	83 c4 10             	add    $0x10,%esp
80100bbe:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bc1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bc5:	75 0f                	jne    80100bd6 <exec+0x34>
    end_op();
80100bc7:	e8 16 2a 00 00       	call   801035e2 <end_op>
    return -1;
80100bcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bd1:	e9 ce 03 00 00       	jmp    80100fa4 <exec+0x402>
  }
  ilock(ip);
80100bd6:	83 ec 0c             	sub    $0xc,%esp
80100bd9:	ff 75 d8             	push   -0x28(%ebp)
80100bdc:	e8 a8 0d 00 00       	call   80101989 <ilock>
80100be1:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100be4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100beb:	6a 34                	push   $0x34
80100bed:	6a 00                	push   $0x0
80100bef:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100bf5:	50                   	push   %eax
80100bf6:	ff 75 d8             	push   -0x28(%ebp)
80100bf9:	e8 f4 12 00 00       	call   80101ef2 <readi>
80100bfe:	83 c4 10             	add    $0x10,%esp
80100c01:	83 f8 33             	cmp    $0x33,%eax
80100c04:	0f 86 49 03 00 00    	jbe    80100f53 <exec+0x3b1>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c0a:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100c10:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c15:	0f 85 3b 03 00 00    	jne    80100f56 <exec+0x3b4>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c1b:	e8 2a 71 00 00       	call   80107d4a <setupkvm>
80100c20:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c23:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c27:	0f 84 2c 03 00 00    	je     80100f59 <exec+0x3b7>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c2d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c34:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c3b:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100c41:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c44:	e9 ab 00 00 00       	jmp    80100cf4 <exec+0x152>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c49:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c4c:	6a 20                	push   $0x20
80100c4e:	50                   	push   %eax
80100c4f:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100c55:	50                   	push   %eax
80100c56:	ff 75 d8             	push   -0x28(%ebp)
80100c59:	e8 94 12 00 00       	call   80101ef2 <readi>
80100c5e:	83 c4 10             	add    $0x10,%esp
80100c61:	83 f8 20             	cmp    $0x20,%eax
80100c64:	0f 85 f2 02 00 00    	jne    80100f5c <exec+0x3ba>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c6a:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c70:	83 f8 01             	cmp    $0x1,%eax
80100c73:	75 71                	jne    80100ce6 <exec+0x144>
      continue;
    if(ph.memsz < ph.filesz)
80100c75:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c7b:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c81:	39 c2                	cmp    %eax,%edx
80100c83:	0f 82 d6 02 00 00    	jb     80100f5f <exec+0x3bd>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c89:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c8f:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c95:	01 d0                	add    %edx,%eax
80100c97:	83 ec 04             	sub    $0x4,%esp
80100c9a:	50                   	push   %eax
80100c9b:	ff 75 e0             	push   -0x20(%ebp)
80100c9e:	ff 75 d4             	push   -0x2c(%ebp)
80100ca1:	e8 4c 74 00 00       	call   801080f2 <allocuvm>
80100ca6:	83 c4 10             	add    $0x10,%esp
80100ca9:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100cac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cb0:	0f 84 ac 02 00 00    	je     80100f62 <exec+0x3c0>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cb6:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100cbc:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cc2:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100cc8:	83 ec 0c             	sub    $0xc,%esp
80100ccb:	52                   	push   %edx
80100ccc:	50                   	push   %eax
80100ccd:	ff 75 d8             	push   -0x28(%ebp)
80100cd0:	51                   	push   %ecx
80100cd1:	ff 75 d4             	push   -0x2c(%ebp)
80100cd4:	e8 42 73 00 00       	call   8010801b <loaduvm>
80100cd9:	83 c4 20             	add    $0x20,%esp
80100cdc:	85 c0                	test   %eax,%eax
80100cde:	0f 88 81 02 00 00    	js     80100f65 <exec+0x3c3>
80100ce4:	eb 01                	jmp    80100ce7 <exec+0x145>
      continue;
80100ce6:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ce7:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100ceb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cee:	83 c0 20             	add    $0x20,%eax
80100cf1:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cf4:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100cfb:	0f b7 c0             	movzwl %ax,%eax
80100cfe:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d01:	0f 8c 42 ff ff ff    	jl     80100c49 <exec+0xa7>
      goto bad;
  }
  iunlockput(ip);
80100d07:	83 ec 0c             	sub    $0xc,%esp
80100d0a:	ff 75 d8             	push   -0x28(%ebp)
80100d0d:	e8 37 0f 00 00       	call   80101c49 <iunlockput>
80100d12:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d15:	e8 c8 28 00 00       	call   801035e2 <end_op>
  ip = 0;
80100d1a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d21:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d24:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d29:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d2e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d31:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d34:	05 00 20 00 00       	add    $0x2000,%eax
80100d39:	83 ec 04             	sub    $0x4,%esp
80100d3c:	50                   	push   %eax
80100d3d:	ff 75 e0             	push   -0x20(%ebp)
80100d40:	ff 75 d4             	push   -0x2c(%ebp)
80100d43:	e8 aa 73 00 00       	call   801080f2 <allocuvm>
80100d48:	83 c4 10             	add    $0x10,%esp
80100d4b:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d4e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d52:	0f 84 10 02 00 00    	je     80100f68 <exec+0x3c6>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d58:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d5b:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d60:	83 ec 08             	sub    $0x8,%esp
80100d63:	50                   	push   %eax
80100d64:	ff 75 d4             	push   -0x2c(%ebp)
80100d67:	e8 aa 75 00 00       	call   80108316 <clearpteu>
80100d6c:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d6f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d72:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d75:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d7c:	e9 96 00 00 00       	jmp    80100e17 <exec+0x275>
    if(argc >= MAXARG)
80100d81:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d85:	0f 87 e0 01 00 00    	ja     80100f6b <exec+0x3c9>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d8e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d95:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d98:	01 d0                	add    %edx,%eax
80100d9a:	8b 00                	mov    (%eax),%eax
80100d9c:	83 ec 0c             	sub    $0xc,%esp
80100d9f:	50                   	push   %eax
80100da0:	e8 52 47 00 00       	call   801054f7 <strlen>
80100da5:	83 c4 10             	add    $0x10,%esp
80100da8:	89 c2                	mov    %eax,%edx
80100daa:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dad:	29 d0                	sub    %edx,%eax
80100daf:	83 e8 01             	sub    $0x1,%eax
80100db2:	83 e0 fc             	and    $0xfffffffc,%eax
80100db5:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100db8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dbb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dc5:	01 d0                	add    %edx,%eax
80100dc7:	8b 00                	mov    (%eax),%eax
80100dc9:	83 ec 0c             	sub    $0xc,%esp
80100dcc:	50                   	push   %eax
80100dcd:	e8 25 47 00 00       	call   801054f7 <strlen>
80100dd2:	83 c4 10             	add    $0x10,%esp
80100dd5:	83 c0 01             	add    $0x1,%eax
80100dd8:	89 c1                	mov    %eax,%ecx
80100dda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ddd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100de4:	8b 45 0c             	mov    0xc(%ebp),%eax
80100de7:	01 d0                	add    %edx,%eax
80100de9:	8b 00                	mov    (%eax),%eax
80100deb:	51                   	push   %ecx
80100dec:	50                   	push   %eax
80100ded:	ff 75 dc             	push   -0x24(%ebp)
80100df0:	ff 75 d4             	push   -0x2c(%ebp)
80100df3:	e8 d4 76 00 00       	call   801084cc <copyout>
80100df8:	83 c4 10             	add    $0x10,%esp
80100dfb:	85 c0                	test   %eax,%eax
80100dfd:	0f 88 6b 01 00 00    	js     80100f6e <exec+0x3cc>
      goto bad;
    ustack[3+argc] = sp;
80100e03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e06:	8d 50 03             	lea    0x3(%eax),%edx
80100e09:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e0c:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e13:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e1a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e21:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e24:	01 d0                	add    %edx,%eax
80100e26:	8b 00                	mov    (%eax),%eax
80100e28:	85 c0                	test   %eax,%eax
80100e2a:	0f 85 51 ff ff ff    	jne    80100d81 <exec+0x1df>
  }
  ustack[3+argc] = 0;
80100e30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e33:	83 c0 03             	add    $0x3,%eax
80100e36:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100e3d:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e41:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100e48:	ff ff ff 
  ustack[1] = argc;
80100e4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4e:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e57:	83 c0 01             	add    $0x1,%eax
80100e5a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e61:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e64:	29 d0                	sub    %edx,%eax
80100e66:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e6f:	83 c0 04             	add    $0x4,%eax
80100e72:	c1 e0 02             	shl    $0x2,%eax
80100e75:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e7b:	83 c0 04             	add    $0x4,%eax
80100e7e:	c1 e0 02             	shl    $0x2,%eax
80100e81:	50                   	push   %eax
80100e82:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e88:	50                   	push   %eax
80100e89:	ff 75 dc             	push   -0x24(%ebp)
80100e8c:	ff 75 d4             	push   -0x2c(%ebp)
80100e8f:	e8 38 76 00 00       	call   801084cc <copyout>
80100e94:	83 c4 10             	add    $0x10,%esp
80100e97:	85 c0                	test   %eax,%eax
80100e99:	0f 88 d2 00 00 00    	js     80100f71 <exec+0x3cf>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e9f:	8b 45 08             	mov    0x8(%ebp),%eax
80100ea2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ea8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100eab:	eb 17                	jmp    80100ec4 <exec+0x322>
    if(*s == '/')
80100ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eb0:	0f b6 00             	movzbl (%eax),%eax
80100eb3:	3c 2f                	cmp    $0x2f,%al
80100eb5:	75 09                	jne    80100ec0 <exec+0x31e>
      last = s+1;
80100eb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eba:	83 c0 01             	add    $0x1,%eax
80100ebd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ec0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ec4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ec7:	0f b6 00             	movzbl (%eax),%eax
80100eca:	84 c0                	test   %al,%al
80100ecc:	75 df                	jne    80100ead <exec+0x30b>
  safestrcpy(proc->name, last, sizeof(proc->name));
80100ece:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed4:	83 c0 6c             	add    $0x6c,%eax
80100ed7:	83 ec 04             	sub    $0x4,%esp
80100eda:	6a 10                	push   $0x10
80100edc:	ff 75 f0             	push   -0x10(%ebp)
80100edf:	50                   	push   %eax
80100ee0:	e8 c7 45 00 00       	call   801054ac <safestrcpy>
80100ee5:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100ee8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eee:	8b 40 04             	mov    0x4(%eax),%eax
80100ef1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100ef4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100efa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100efd:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100f00:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f06:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f09:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100f0b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f11:	8b 40 18             	mov    0x18(%eax),%eax
80100f14:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100f1a:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100f1d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f23:	8b 40 18             	mov    0x18(%eax),%eax
80100f26:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f29:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100f2c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f32:	83 ec 0c             	sub    $0xc,%esp
80100f35:	50                   	push   %eax
80100f36:	e8 f6 6e 00 00       	call   80107e31 <switchuvm>
80100f3b:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f3e:	83 ec 0c             	sub    $0xc,%esp
80100f41:	ff 75 d0             	push   -0x30(%ebp)
80100f44:	e8 2d 73 00 00       	call   80108276 <freevm>
80100f49:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f4c:	b8 00 00 00 00       	mov    $0x0,%eax
80100f51:	eb 51                	jmp    80100fa4 <exec+0x402>
    goto bad;
80100f53:	90                   	nop
80100f54:	eb 1c                	jmp    80100f72 <exec+0x3d0>
    goto bad;
80100f56:	90                   	nop
80100f57:	eb 19                	jmp    80100f72 <exec+0x3d0>
    goto bad;
80100f59:	90                   	nop
80100f5a:	eb 16                	jmp    80100f72 <exec+0x3d0>
      goto bad;
80100f5c:	90                   	nop
80100f5d:	eb 13                	jmp    80100f72 <exec+0x3d0>
      goto bad;
80100f5f:	90                   	nop
80100f60:	eb 10                	jmp    80100f72 <exec+0x3d0>
      goto bad;
80100f62:	90                   	nop
80100f63:	eb 0d                	jmp    80100f72 <exec+0x3d0>
      goto bad;
80100f65:	90                   	nop
80100f66:	eb 0a                	jmp    80100f72 <exec+0x3d0>
    goto bad;
80100f68:	90                   	nop
80100f69:	eb 07                	jmp    80100f72 <exec+0x3d0>
      goto bad;
80100f6b:	90                   	nop
80100f6c:	eb 04                	jmp    80100f72 <exec+0x3d0>
      goto bad;
80100f6e:	90                   	nop
80100f6f:	eb 01                	jmp    80100f72 <exec+0x3d0>
    goto bad;
80100f71:	90                   	nop

 bad:
  if(pgdir)
80100f72:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f76:	74 0e                	je     80100f86 <exec+0x3e4>
    freevm(pgdir);
80100f78:	83 ec 0c             	sub    $0xc,%esp
80100f7b:	ff 75 d4             	push   -0x2c(%ebp)
80100f7e:	e8 f3 72 00 00       	call   80108276 <freevm>
80100f83:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f86:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f8a:	74 13                	je     80100f9f <exec+0x3fd>
    iunlockput(ip);
80100f8c:	83 ec 0c             	sub    $0xc,%esp
80100f8f:	ff 75 d8             	push   -0x28(%ebp)
80100f92:	e8 b2 0c 00 00       	call   80101c49 <iunlockput>
80100f97:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f9a:	e8 43 26 00 00       	call   801035e2 <end_op>
  }
  return -1;
80100f9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fa4:	c9                   	leave
80100fa5:	c3                   	ret

80100fa6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fa6:	55                   	push   %ebp
80100fa7:	89 e5                	mov    %esp,%ebp
80100fa9:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fac:	83 ec 08             	sub    $0x8,%esp
80100faf:	68 d2 85 10 80       	push   $0x801085d2
80100fb4:	68 00 f8 10 80       	push   $0x8010f800
80100fb9:	e8 65 40 00 00       	call   80105023 <initlock>
80100fbe:	83 c4 10             	add    $0x10,%esp
}
80100fc1:	90                   	nop
80100fc2:	c9                   	leave
80100fc3:	c3                   	ret

80100fc4 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fc4:	55                   	push   %ebp
80100fc5:	89 e5                	mov    %esp,%ebp
80100fc7:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fca:	83 ec 0c             	sub    $0xc,%esp
80100fcd:	68 00 f8 10 80       	push   $0x8010f800
80100fd2:	e8 6e 40 00 00       	call   80105045 <acquire>
80100fd7:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fda:	c7 45 f4 34 f8 10 80 	movl   $0x8010f834,-0xc(%ebp)
80100fe1:	eb 2d                	jmp    80101010 <filealloc+0x4c>
    if(f->ref == 0){
80100fe3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fe6:	8b 40 04             	mov    0x4(%eax),%eax
80100fe9:	85 c0                	test   %eax,%eax
80100feb:	75 1f                	jne    8010100c <filealloc+0x48>
      f->ref = 1;
80100fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ff0:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100ff7:	83 ec 0c             	sub    $0xc,%esp
80100ffa:	68 00 f8 10 80       	push   $0x8010f800
80100fff:	e8 a8 40 00 00       	call   801050ac <release>
80101004:	83 c4 10             	add    $0x10,%esp
      return f;
80101007:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010100a:	eb 23                	jmp    8010102f <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010100c:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101010:	b8 94 01 11 80       	mov    $0x80110194,%eax
80101015:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101018:	72 c9                	jb     80100fe3 <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
8010101a:	83 ec 0c             	sub    $0xc,%esp
8010101d:	68 00 f8 10 80       	push   $0x8010f800
80101022:	e8 85 40 00 00       	call   801050ac <release>
80101027:	83 c4 10             	add    $0x10,%esp
  return 0;
8010102a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010102f:	c9                   	leave
80101030:	c3                   	ret

80101031 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101031:	55                   	push   %ebp
80101032:	89 e5                	mov    %esp,%ebp
80101034:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101037:	83 ec 0c             	sub    $0xc,%esp
8010103a:	68 00 f8 10 80       	push   $0x8010f800
8010103f:	e8 01 40 00 00       	call   80105045 <acquire>
80101044:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101047:	8b 45 08             	mov    0x8(%ebp),%eax
8010104a:	8b 40 04             	mov    0x4(%eax),%eax
8010104d:	85 c0                	test   %eax,%eax
8010104f:	7f 0d                	jg     8010105e <filedup+0x2d>
    panic("filedup");
80101051:	83 ec 0c             	sub    $0xc,%esp
80101054:	68 d9 85 10 80       	push   $0x801085d9
80101059:	e8 1b f5 ff ff       	call   80100579 <panic>
  f->ref++;
8010105e:	8b 45 08             	mov    0x8(%ebp),%eax
80101061:	8b 40 04             	mov    0x4(%eax),%eax
80101064:	8d 50 01             	lea    0x1(%eax),%edx
80101067:	8b 45 08             	mov    0x8(%ebp),%eax
8010106a:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
8010106d:	83 ec 0c             	sub    $0xc,%esp
80101070:	68 00 f8 10 80       	push   $0x8010f800
80101075:	e8 32 40 00 00       	call   801050ac <release>
8010107a:	83 c4 10             	add    $0x10,%esp
  return f;
8010107d:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101080:	c9                   	leave
80101081:	c3                   	ret

80101082 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101082:	55                   	push   %ebp
80101083:	89 e5                	mov    %esp,%ebp
80101085:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101088:	83 ec 0c             	sub    $0xc,%esp
8010108b:	68 00 f8 10 80       	push   $0x8010f800
80101090:	e8 b0 3f 00 00       	call   80105045 <acquire>
80101095:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101098:	8b 45 08             	mov    0x8(%ebp),%eax
8010109b:	8b 40 04             	mov    0x4(%eax),%eax
8010109e:	85 c0                	test   %eax,%eax
801010a0:	7f 0d                	jg     801010af <fileclose+0x2d>
    panic("fileclose");
801010a2:	83 ec 0c             	sub    $0xc,%esp
801010a5:	68 e1 85 10 80       	push   $0x801085e1
801010aa:	e8 ca f4 ff ff       	call   80100579 <panic>
  if(--f->ref > 0){
801010af:	8b 45 08             	mov    0x8(%ebp),%eax
801010b2:	8b 40 04             	mov    0x4(%eax),%eax
801010b5:	8d 50 ff             	lea    -0x1(%eax),%edx
801010b8:	8b 45 08             	mov    0x8(%ebp),%eax
801010bb:	89 50 04             	mov    %edx,0x4(%eax)
801010be:	8b 45 08             	mov    0x8(%ebp),%eax
801010c1:	8b 40 04             	mov    0x4(%eax),%eax
801010c4:	85 c0                	test   %eax,%eax
801010c6:	7e 15                	jle    801010dd <fileclose+0x5b>
    release(&ftable.lock);
801010c8:	83 ec 0c             	sub    $0xc,%esp
801010cb:	68 00 f8 10 80       	push   $0x8010f800
801010d0:	e8 d7 3f 00 00       	call   801050ac <release>
801010d5:	83 c4 10             	add    $0x10,%esp
801010d8:	e9 8b 00 00 00       	jmp    80101168 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010dd:	8b 45 08             	mov    0x8(%ebp),%eax
801010e0:	8b 10                	mov    (%eax),%edx
801010e2:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010e5:	8b 50 04             	mov    0x4(%eax),%edx
801010e8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801010eb:	8b 50 08             	mov    0x8(%eax),%edx
801010ee:	89 55 e8             	mov    %edx,-0x18(%ebp)
801010f1:	8b 50 0c             	mov    0xc(%eax),%edx
801010f4:	89 55 ec             	mov    %edx,-0x14(%ebp)
801010f7:	8b 50 10             	mov    0x10(%eax),%edx
801010fa:	89 55 f0             	mov    %edx,-0x10(%ebp)
801010fd:	8b 40 14             	mov    0x14(%eax),%eax
80101100:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101103:	8b 45 08             	mov    0x8(%ebp),%eax
80101106:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010110d:	8b 45 08             	mov    0x8(%ebp),%eax
80101110:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101116:	83 ec 0c             	sub    $0xc,%esp
80101119:	68 00 f8 10 80       	push   $0x8010f800
8010111e:	e8 89 3f 00 00       	call   801050ac <release>
80101123:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
80101126:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101129:	83 f8 01             	cmp    $0x1,%eax
8010112c:	75 19                	jne    80101147 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
8010112e:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101132:	0f be d0             	movsbl %al,%edx
80101135:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101138:	83 ec 08             	sub    $0x8,%esp
8010113b:	52                   	push   %edx
8010113c:	50                   	push   %eax
8010113d:	e8 74 30 00 00       	call   801041b6 <pipeclose>
80101142:	83 c4 10             	add    $0x10,%esp
80101145:	eb 21                	jmp    80101168 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101147:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010114a:	83 f8 02             	cmp    $0x2,%eax
8010114d:	75 19                	jne    80101168 <fileclose+0xe6>
    begin_op();
8010114f:	e8 02 24 00 00       	call   80103556 <begin_op>
    iput(ff.ip);
80101154:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101157:	83 ec 0c             	sub    $0xc,%esp
8010115a:	50                   	push   %eax
8010115b:	e8 f9 09 00 00       	call   80101b59 <iput>
80101160:	83 c4 10             	add    $0x10,%esp
    end_op();
80101163:	e8 7a 24 00 00       	call   801035e2 <end_op>
  }
}
80101168:	c9                   	leave
80101169:	c3                   	ret

8010116a <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010116a:	55                   	push   %ebp
8010116b:	89 e5                	mov    %esp,%ebp
8010116d:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101170:	8b 45 08             	mov    0x8(%ebp),%eax
80101173:	8b 00                	mov    (%eax),%eax
80101175:	83 f8 02             	cmp    $0x2,%eax
80101178:	75 40                	jne    801011ba <filestat+0x50>
    ilock(f->ip);
8010117a:	8b 45 08             	mov    0x8(%ebp),%eax
8010117d:	8b 40 10             	mov    0x10(%eax),%eax
80101180:	83 ec 0c             	sub    $0xc,%esp
80101183:	50                   	push   %eax
80101184:	e8 00 08 00 00       	call   80101989 <ilock>
80101189:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
8010118c:	8b 45 08             	mov    0x8(%ebp),%eax
8010118f:	8b 40 10             	mov    0x10(%eax),%eax
80101192:	83 ec 08             	sub    $0x8,%esp
80101195:	ff 75 0c             	push   0xc(%ebp)
80101198:	50                   	push   %eax
80101199:	e8 0e 0d 00 00       	call   80101eac <stati>
8010119e:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011a1:	8b 45 08             	mov    0x8(%ebp),%eax
801011a4:	8b 40 10             	mov    0x10(%eax),%eax
801011a7:	83 ec 0c             	sub    $0xc,%esp
801011aa:	50                   	push   %eax
801011ab:	e8 37 09 00 00       	call   80101ae7 <iunlock>
801011b0:	83 c4 10             	add    $0x10,%esp
    return 0;
801011b3:	b8 00 00 00 00       	mov    $0x0,%eax
801011b8:	eb 05                	jmp    801011bf <filestat+0x55>
  }
  return -1;
801011ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011bf:	c9                   	leave
801011c0:	c3                   	ret

801011c1 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011c1:	55                   	push   %ebp
801011c2:	89 e5                	mov    %esp,%ebp
801011c4:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011c7:	8b 45 08             	mov    0x8(%ebp),%eax
801011ca:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011ce:	84 c0                	test   %al,%al
801011d0:	75 0a                	jne    801011dc <fileread+0x1b>
    return -1;
801011d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011d7:	e9 9b 00 00 00       	jmp    80101277 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011dc:	8b 45 08             	mov    0x8(%ebp),%eax
801011df:	8b 00                	mov    (%eax),%eax
801011e1:	83 f8 01             	cmp    $0x1,%eax
801011e4:	75 1a                	jne    80101200 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011e6:	8b 45 08             	mov    0x8(%ebp),%eax
801011e9:	8b 40 0c             	mov    0xc(%eax),%eax
801011ec:	83 ec 04             	sub    $0x4,%esp
801011ef:	ff 75 10             	push   0x10(%ebp)
801011f2:	ff 75 0c             	push   0xc(%ebp)
801011f5:	50                   	push   %eax
801011f6:	e8 69 31 00 00       	call   80104364 <piperead>
801011fb:	83 c4 10             	add    $0x10,%esp
801011fe:	eb 77                	jmp    80101277 <fileread+0xb6>
  if(f->type == FD_INODE){
80101200:	8b 45 08             	mov    0x8(%ebp),%eax
80101203:	8b 00                	mov    (%eax),%eax
80101205:	83 f8 02             	cmp    $0x2,%eax
80101208:	75 60                	jne    8010126a <fileread+0xa9>
    ilock(f->ip);
8010120a:	8b 45 08             	mov    0x8(%ebp),%eax
8010120d:	8b 40 10             	mov    0x10(%eax),%eax
80101210:	83 ec 0c             	sub    $0xc,%esp
80101213:	50                   	push   %eax
80101214:	e8 70 07 00 00       	call   80101989 <ilock>
80101219:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010121c:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010121f:	8b 45 08             	mov    0x8(%ebp),%eax
80101222:	8b 50 14             	mov    0x14(%eax),%edx
80101225:	8b 45 08             	mov    0x8(%ebp),%eax
80101228:	8b 40 10             	mov    0x10(%eax),%eax
8010122b:	51                   	push   %ecx
8010122c:	52                   	push   %edx
8010122d:	ff 75 0c             	push   0xc(%ebp)
80101230:	50                   	push   %eax
80101231:	e8 bc 0c 00 00       	call   80101ef2 <readi>
80101236:	83 c4 10             	add    $0x10,%esp
80101239:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010123c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101240:	7e 11                	jle    80101253 <fileread+0x92>
      f->off += r;
80101242:	8b 45 08             	mov    0x8(%ebp),%eax
80101245:	8b 50 14             	mov    0x14(%eax),%edx
80101248:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010124b:	01 c2                	add    %eax,%edx
8010124d:	8b 45 08             	mov    0x8(%ebp),%eax
80101250:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101253:	8b 45 08             	mov    0x8(%ebp),%eax
80101256:	8b 40 10             	mov    0x10(%eax),%eax
80101259:	83 ec 0c             	sub    $0xc,%esp
8010125c:	50                   	push   %eax
8010125d:	e8 85 08 00 00       	call   80101ae7 <iunlock>
80101262:	83 c4 10             	add    $0x10,%esp
    return r;
80101265:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101268:	eb 0d                	jmp    80101277 <fileread+0xb6>
  }
  panic("fileread");
8010126a:	83 ec 0c             	sub    $0xc,%esp
8010126d:	68 eb 85 10 80       	push   $0x801085eb
80101272:	e8 02 f3 ff ff       	call   80100579 <panic>
}
80101277:	c9                   	leave
80101278:	c3                   	ret

80101279 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101279:	55                   	push   %ebp
8010127a:	89 e5                	mov    %esp,%ebp
8010127c:	53                   	push   %ebx
8010127d:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101280:	8b 45 08             	mov    0x8(%ebp),%eax
80101283:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101287:	84 c0                	test   %al,%al
80101289:	75 0a                	jne    80101295 <filewrite+0x1c>
    return -1;
8010128b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101290:	e9 1b 01 00 00       	jmp    801013b0 <filewrite+0x137>
  if(f->type == FD_PIPE)
80101295:	8b 45 08             	mov    0x8(%ebp),%eax
80101298:	8b 00                	mov    (%eax),%eax
8010129a:	83 f8 01             	cmp    $0x1,%eax
8010129d:	75 1d                	jne    801012bc <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
8010129f:	8b 45 08             	mov    0x8(%ebp),%eax
801012a2:	8b 40 0c             	mov    0xc(%eax),%eax
801012a5:	83 ec 04             	sub    $0x4,%esp
801012a8:	ff 75 10             	push   0x10(%ebp)
801012ab:	ff 75 0c             	push   0xc(%ebp)
801012ae:	50                   	push   %eax
801012af:	e8 ad 2f 00 00       	call   80104261 <pipewrite>
801012b4:	83 c4 10             	add    $0x10,%esp
801012b7:	e9 f4 00 00 00       	jmp    801013b0 <filewrite+0x137>
  if(f->type == FD_INODE){
801012bc:	8b 45 08             	mov    0x8(%ebp),%eax
801012bf:	8b 00                	mov    (%eax),%eax
801012c1:	83 f8 02             	cmp    $0x2,%eax
801012c4:	0f 85 d9 00 00 00    	jne    801013a3 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801012ca:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801012d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012d8:	e9 a3 00 00 00       	jmp    80101380 <filewrite+0x107>
      int n1 = n - i;
801012dd:	8b 45 10             	mov    0x10(%ebp),%eax
801012e0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012e9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012ec:	7e 06                	jle    801012f4 <filewrite+0x7b>
        n1 = max;
801012ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012f1:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801012f4:	e8 5d 22 00 00       	call   80103556 <begin_op>
      ilock(f->ip);
801012f9:	8b 45 08             	mov    0x8(%ebp),%eax
801012fc:	8b 40 10             	mov    0x10(%eax),%eax
801012ff:	83 ec 0c             	sub    $0xc,%esp
80101302:	50                   	push   %eax
80101303:	e8 81 06 00 00       	call   80101989 <ilock>
80101308:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010130b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010130e:	8b 45 08             	mov    0x8(%ebp),%eax
80101311:	8b 50 14             	mov    0x14(%eax),%edx
80101314:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101317:	8b 45 0c             	mov    0xc(%ebp),%eax
8010131a:	01 c3                	add    %eax,%ebx
8010131c:	8b 45 08             	mov    0x8(%ebp),%eax
8010131f:	8b 40 10             	mov    0x10(%eax),%eax
80101322:	51                   	push   %ecx
80101323:	52                   	push   %edx
80101324:	53                   	push   %ebx
80101325:	50                   	push   %eax
80101326:	e8 1c 0d 00 00       	call   80102047 <writei>
8010132b:	83 c4 10             	add    $0x10,%esp
8010132e:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101331:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101335:	7e 11                	jle    80101348 <filewrite+0xcf>
        f->off += r;
80101337:	8b 45 08             	mov    0x8(%ebp),%eax
8010133a:	8b 50 14             	mov    0x14(%eax),%edx
8010133d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101340:	01 c2                	add    %eax,%edx
80101342:	8b 45 08             	mov    0x8(%ebp),%eax
80101345:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101348:	8b 45 08             	mov    0x8(%ebp),%eax
8010134b:	8b 40 10             	mov    0x10(%eax),%eax
8010134e:	83 ec 0c             	sub    $0xc,%esp
80101351:	50                   	push   %eax
80101352:	e8 90 07 00 00       	call   80101ae7 <iunlock>
80101357:	83 c4 10             	add    $0x10,%esp
      end_op();
8010135a:	e8 83 22 00 00       	call   801035e2 <end_op>

      if(r < 0)
8010135f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101363:	78 29                	js     8010138e <filewrite+0x115>
        break;
      if(r != n1)
80101365:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101368:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010136b:	74 0d                	je     8010137a <filewrite+0x101>
        panic("short filewrite");
8010136d:	83 ec 0c             	sub    $0xc,%esp
80101370:	68 f4 85 10 80       	push   $0x801085f4
80101375:	e8 ff f1 ff ff       	call   80100579 <panic>
      i += r;
8010137a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010137d:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
80101380:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101383:	3b 45 10             	cmp    0x10(%ebp),%eax
80101386:	0f 8c 51 ff ff ff    	jl     801012dd <filewrite+0x64>
8010138c:	eb 01                	jmp    8010138f <filewrite+0x116>
        break;
8010138e:	90                   	nop
    }
    return i == n ? n : -1;
8010138f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101392:	3b 45 10             	cmp    0x10(%ebp),%eax
80101395:	75 05                	jne    8010139c <filewrite+0x123>
80101397:	8b 45 10             	mov    0x10(%ebp),%eax
8010139a:	eb 14                	jmp    801013b0 <filewrite+0x137>
8010139c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013a1:	eb 0d                	jmp    801013b0 <filewrite+0x137>
  }
  panic("filewrite");
801013a3:	83 ec 0c             	sub    $0xc,%esp
801013a6:	68 04 86 10 80       	push   $0x80108604
801013ab:	e8 c9 f1 ff ff       	call   80100579 <panic>
}
801013b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013b3:	c9                   	leave
801013b4:	c3                   	ret

801013b5 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013b5:	55                   	push   %ebp
801013b6:	89 e5                	mov    %esp,%ebp
801013b8:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801013bb:	8b 45 08             	mov    0x8(%ebp),%eax
801013be:	83 ec 08             	sub    $0x8,%esp
801013c1:	6a 01                	push   $0x1
801013c3:	50                   	push   %eax
801013c4:	e8 ee ed ff ff       	call   801001b7 <bread>
801013c9:	83 c4 10             	add    $0x10,%esp
801013cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013d2:	83 c0 18             	add    $0x18,%eax
801013d5:	83 ec 04             	sub    $0x4,%esp
801013d8:	6a 1c                	push   $0x1c
801013da:	50                   	push   %eax
801013db:	ff 75 0c             	push   0xc(%ebp)
801013de:	e8 85 3f 00 00       	call   80105368 <memmove>
801013e3:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013e6:	83 ec 0c             	sub    $0xc,%esp
801013e9:	ff 75 f4             	push   -0xc(%ebp)
801013ec:	e8 3e ee ff ff       	call   8010022f <brelse>
801013f1:	83 c4 10             	add    $0x10,%esp
}
801013f4:	90                   	nop
801013f5:	c9                   	leave
801013f6:	c3                   	ret

801013f7 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801013f7:	55                   	push   %ebp
801013f8:	89 e5                	mov    %esp,%ebp
801013fa:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801013fd:	8b 55 0c             	mov    0xc(%ebp),%edx
80101400:	8b 45 08             	mov    0x8(%ebp),%eax
80101403:	83 ec 08             	sub    $0x8,%esp
80101406:	52                   	push   %edx
80101407:	50                   	push   %eax
80101408:	e8 aa ed ff ff       	call   801001b7 <bread>
8010140d:	83 c4 10             	add    $0x10,%esp
80101410:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101413:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101416:	83 c0 18             	add    $0x18,%eax
80101419:	83 ec 04             	sub    $0x4,%esp
8010141c:	68 00 02 00 00       	push   $0x200
80101421:	6a 00                	push   $0x0
80101423:	50                   	push   %eax
80101424:	e8 80 3e 00 00       	call   801052a9 <memset>
80101429:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010142c:	83 ec 0c             	sub    $0xc,%esp
8010142f:	ff 75 f4             	push   -0xc(%ebp)
80101432:	e8 58 23 00 00       	call   8010378f <log_write>
80101437:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010143a:	83 ec 0c             	sub    $0xc,%esp
8010143d:	ff 75 f4             	push   -0xc(%ebp)
80101440:	e8 ea ed ff ff       	call   8010022f <brelse>
80101445:	83 c4 10             	add    $0x10,%esp
}
80101448:	90                   	nop
80101449:	c9                   	leave
8010144a:	c3                   	ret

8010144b <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010144b:	55                   	push   %ebp
8010144c:	89 e5                	mov    %esp,%ebp
8010144e:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101451:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101458:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010145f:	e9 0b 01 00 00       	jmp    8010156f <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
80101464:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101467:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
8010146d:	85 c0                	test   %eax,%eax
8010146f:	0f 48 c2             	cmovs  %edx,%eax
80101472:	c1 f8 0c             	sar    $0xc,%eax
80101475:	89 c2                	mov    %eax,%edx
80101477:	a1 b8 01 11 80       	mov    0x801101b8,%eax
8010147c:	01 d0                	add    %edx,%eax
8010147e:	83 ec 08             	sub    $0x8,%esp
80101481:	50                   	push   %eax
80101482:	ff 75 08             	push   0x8(%ebp)
80101485:	e8 2d ed ff ff       	call   801001b7 <bread>
8010148a:	83 c4 10             	add    $0x10,%esp
8010148d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101490:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101497:	e9 9e 00 00 00       	jmp    8010153a <balloc+0xef>
      m = 1 << (bi % 8);
8010149c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010149f:	83 e0 07             	and    $0x7,%eax
801014a2:	ba 01 00 00 00       	mov    $0x1,%edx
801014a7:	89 c1                	mov    %eax,%ecx
801014a9:	d3 e2                	shl    %cl,%edx
801014ab:	89 d0                	mov    %edx,%eax
801014ad:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014b3:	8d 50 07             	lea    0x7(%eax),%edx
801014b6:	85 c0                	test   %eax,%eax
801014b8:	0f 48 c2             	cmovs  %edx,%eax
801014bb:	c1 f8 03             	sar    $0x3,%eax
801014be:	89 c2                	mov    %eax,%edx
801014c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014c3:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801014c8:	0f b6 c0             	movzbl %al,%eax
801014cb:	23 45 e8             	and    -0x18(%ebp),%eax
801014ce:	85 c0                	test   %eax,%eax
801014d0:	75 64                	jne    80101536 <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014d5:	8d 50 07             	lea    0x7(%eax),%edx
801014d8:	85 c0                	test   %eax,%eax
801014da:	0f 48 c2             	cmovs  %edx,%eax
801014dd:	c1 f8 03             	sar    $0x3,%eax
801014e0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014e3:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801014e8:	89 d1                	mov    %edx,%ecx
801014ea:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014ed:	09 ca                	or     %ecx,%edx
801014ef:	89 d1                	mov    %edx,%ecx
801014f1:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014f4:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801014f8:	83 ec 0c             	sub    $0xc,%esp
801014fb:	ff 75 ec             	push   -0x14(%ebp)
801014fe:	e8 8c 22 00 00       	call   8010378f <log_write>
80101503:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101506:	83 ec 0c             	sub    $0xc,%esp
80101509:	ff 75 ec             	push   -0x14(%ebp)
8010150c:	e8 1e ed ff ff       	call   8010022f <brelse>
80101511:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101514:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101517:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010151a:	01 c2                	add    %eax,%edx
8010151c:	8b 45 08             	mov    0x8(%ebp),%eax
8010151f:	83 ec 08             	sub    $0x8,%esp
80101522:	52                   	push   %edx
80101523:	50                   	push   %eax
80101524:	e8 ce fe ff ff       	call   801013f7 <bzero>
80101529:	83 c4 10             	add    $0x10,%esp
        return b + bi;
8010152c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010152f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101532:	01 d0                	add    %edx,%eax
80101534:	eb 56                	jmp    8010158c <balloc+0x141>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101536:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010153a:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101541:	7f 17                	jg     8010155a <balloc+0x10f>
80101543:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101546:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101549:	01 d0                	add    %edx,%eax
8010154b:	89 c2                	mov    %eax,%edx
8010154d:	a1 a0 01 11 80       	mov    0x801101a0,%eax
80101552:	39 c2                	cmp    %eax,%edx
80101554:	0f 82 42 ff ff ff    	jb     8010149c <balloc+0x51>
      }
    }
    brelse(bp);
8010155a:	83 ec 0c             	sub    $0xc,%esp
8010155d:	ff 75 ec             	push   -0x14(%ebp)
80101560:	e8 ca ec ff ff       	call   8010022f <brelse>
80101565:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101568:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010156f:	a1 a0 01 11 80       	mov    0x801101a0,%eax
80101574:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101577:	39 c2                	cmp    %eax,%edx
80101579:	0f 82 e5 fe ff ff    	jb     80101464 <balloc+0x19>
  }
  panic("balloc: out of blocks");
8010157f:	83 ec 0c             	sub    $0xc,%esp
80101582:	68 10 86 10 80       	push   $0x80108610
80101587:	e8 ed ef ff ff       	call   80100579 <panic>
}
8010158c:	c9                   	leave
8010158d:	c3                   	ret

8010158e <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010158e:	55                   	push   %ebp
8010158f:	89 e5                	mov    %esp,%ebp
80101591:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101594:	83 ec 08             	sub    $0x8,%esp
80101597:	68 a0 01 11 80       	push   $0x801101a0
8010159c:	ff 75 08             	push   0x8(%ebp)
8010159f:	e8 11 fe ff ff       	call   801013b5 <readsb>
801015a4:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801015aa:	c1 e8 0c             	shr    $0xc,%eax
801015ad:	89 c2                	mov    %eax,%edx
801015af:	a1 b8 01 11 80       	mov    0x801101b8,%eax
801015b4:	01 c2                	add    %eax,%edx
801015b6:	8b 45 08             	mov    0x8(%ebp),%eax
801015b9:	83 ec 08             	sub    $0x8,%esp
801015bc:	52                   	push   %edx
801015bd:	50                   	push   %eax
801015be:	e8 f4 eb ff ff       	call   801001b7 <bread>
801015c3:	83 c4 10             	add    $0x10,%esp
801015c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801015cc:	25 ff 0f 00 00       	and    $0xfff,%eax
801015d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015d7:	83 e0 07             	and    $0x7,%eax
801015da:	ba 01 00 00 00       	mov    $0x1,%edx
801015df:	89 c1                	mov    %eax,%ecx
801015e1:	d3 e2                	shl    %cl,%edx
801015e3:	89 d0                	mov    %edx,%eax
801015e5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015eb:	8d 50 07             	lea    0x7(%eax),%edx
801015ee:	85 c0                	test   %eax,%eax
801015f0:	0f 48 c2             	cmovs  %edx,%eax
801015f3:	c1 f8 03             	sar    $0x3,%eax
801015f6:	89 c2                	mov    %eax,%edx
801015f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015fb:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101600:	0f b6 c0             	movzbl %al,%eax
80101603:	23 45 ec             	and    -0x14(%ebp),%eax
80101606:	85 c0                	test   %eax,%eax
80101608:	75 0d                	jne    80101617 <bfree+0x89>
    panic("freeing free block");
8010160a:	83 ec 0c             	sub    $0xc,%esp
8010160d:	68 26 86 10 80       	push   $0x80108626
80101612:	e8 62 ef ff ff       	call   80100579 <panic>
  bp->data[bi/8] &= ~m;
80101617:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010161a:	8d 50 07             	lea    0x7(%eax),%edx
8010161d:	85 c0                	test   %eax,%eax
8010161f:	0f 48 c2             	cmovs  %edx,%eax
80101622:	c1 f8 03             	sar    $0x3,%eax
80101625:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101628:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010162d:	89 d1                	mov    %edx,%ecx
8010162f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101632:	f7 d2                	not    %edx
80101634:	21 ca                	and    %ecx,%edx
80101636:	89 d1                	mov    %edx,%ecx
80101638:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010163b:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
8010163f:	83 ec 0c             	sub    $0xc,%esp
80101642:	ff 75 f4             	push   -0xc(%ebp)
80101645:	e8 45 21 00 00       	call   8010378f <log_write>
8010164a:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010164d:	83 ec 0c             	sub    $0xc,%esp
80101650:	ff 75 f4             	push   -0xc(%ebp)
80101653:	e8 d7 eb ff ff       	call   8010022f <brelse>
80101658:	83 c4 10             	add    $0x10,%esp
}
8010165b:	90                   	nop
8010165c:	c9                   	leave
8010165d:	c3                   	ret

8010165e <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
8010165e:	55                   	push   %ebp
8010165f:	89 e5                	mov    %esp,%ebp
80101661:	57                   	push   %edi
80101662:	56                   	push   %esi
80101663:	53                   	push   %ebx
80101664:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
80101667:	83 ec 08             	sub    $0x8,%esp
8010166a:	68 39 86 10 80       	push   $0x80108639
8010166f:	68 c0 01 11 80       	push   $0x801101c0
80101674:	e8 aa 39 00 00       	call   80105023 <initlock>
80101679:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010167c:	83 ec 08             	sub    $0x8,%esp
8010167f:	68 a0 01 11 80       	push   $0x801101a0
80101684:	ff 75 08             	push   0x8(%ebp)
80101687:	e8 29 fd ff ff       	call   801013b5 <readsb>
8010168c:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
8010168f:	a1 b8 01 11 80       	mov    0x801101b8,%eax
80101694:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101697:	8b 3d b4 01 11 80    	mov    0x801101b4,%edi
8010169d:	8b 35 b0 01 11 80    	mov    0x801101b0,%esi
801016a3:	8b 1d ac 01 11 80    	mov    0x801101ac,%ebx
801016a9:	8b 0d a8 01 11 80    	mov    0x801101a8,%ecx
801016af:	8b 15 a4 01 11 80    	mov    0x801101a4,%edx
801016b5:	a1 a0 01 11 80       	mov    0x801101a0,%eax
801016ba:	ff 75 e4             	push   -0x1c(%ebp)
801016bd:	57                   	push   %edi
801016be:	56                   	push   %esi
801016bf:	53                   	push   %ebx
801016c0:	51                   	push   %ecx
801016c1:	52                   	push   %edx
801016c2:	50                   	push   %eax
801016c3:	68 40 86 10 80       	push   $0x80108640
801016c8:	e8 f7 ec ff ff       	call   801003c4 <cprintf>
801016cd:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
801016d0:	90                   	nop
801016d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016d4:	5b                   	pop    %ebx
801016d5:	5e                   	pop    %esi
801016d6:	5f                   	pop    %edi
801016d7:	5d                   	pop    %ebp
801016d8:	c3                   	ret

801016d9 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801016d9:	55                   	push   %ebp
801016da:	89 e5                	mov    %esp,%ebp
801016dc:	83 ec 28             	sub    $0x28,%esp
801016df:	8b 45 0c             	mov    0xc(%ebp),%eax
801016e2:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801016e6:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801016ed:	e9 9e 00 00 00       	jmp    80101790 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801016f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016f5:	c1 e8 03             	shr    $0x3,%eax
801016f8:	89 c2                	mov    %eax,%edx
801016fa:	a1 b4 01 11 80       	mov    0x801101b4,%eax
801016ff:	01 d0                	add    %edx,%eax
80101701:	83 ec 08             	sub    $0x8,%esp
80101704:	50                   	push   %eax
80101705:	ff 75 08             	push   0x8(%ebp)
80101708:	e8 aa ea ff ff       	call   801001b7 <bread>
8010170d:	83 c4 10             	add    $0x10,%esp
80101710:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101713:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101716:	8d 50 18             	lea    0x18(%eax),%edx
80101719:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010171c:	83 e0 07             	and    $0x7,%eax
8010171f:	c1 e0 06             	shl    $0x6,%eax
80101722:	01 d0                	add    %edx,%eax
80101724:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101727:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010172a:	0f b7 00             	movzwl (%eax),%eax
8010172d:	66 85 c0             	test   %ax,%ax
80101730:	75 4c                	jne    8010177e <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101732:	83 ec 04             	sub    $0x4,%esp
80101735:	6a 40                	push   $0x40
80101737:	6a 00                	push   $0x0
80101739:	ff 75 ec             	push   -0x14(%ebp)
8010173c:	e8 68 3b 00 00       	call   801052a9 <memset>
80101741:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101744:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101747:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
8010174b:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010174e:	83 ec 0c             	sub    $0xc,%esp
80101751:	ff 75 f0             	push   -0x10(%ebp)
80101754:	e8 36 20 00 00       	call   8010378f <log_write>
80101759:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
8010175c:	83 ec 0c             	sub    $0xc,%esp
8010175f:	ff 75 f0             	push   -0x10(%ebp)
80101762:	e8 c8 ea ff ff       	call   8010022f <brelse>
80101767:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
8010176a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010176d:	83 ec 08             	sub    $0x8,%esp
80101770:	50                   	push   %eax
80101771:	ff 75 08             	push   0x8(%ebp)
80101774:	e8 f7 00 00 00       	call   80101870 <iget>
80101779:	83 c4 10             	add    $0x10,%esp
8010177c:	eb 2f                	jmp    801017ad <ialloc+0xd4>
    }
    brelse(bp);
8010177e:	83 ec 0c             	sub    $0xc,%esp
80101781:	ff 75 f0             	push   -0x10(%ebp)
80101784:	e8 a6 ea ff ff       	call   8010022f <brelse>
80101789:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
8010178c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101790:	a1 a8 01 11 80       	mov    0x801101a8,%eax
80101795:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101798:	39 c2                	cmp    %eax,%edx
8010179a:	0f 82 52 ff ff ff    	jb     801016f2 <ialloc+0x19>
  }
  panic("ialloc: no inodes");
801017a0:	83 ec 0c             	sub    $0xc,%esp
801017a3:	68 93 86 10 80       	push   $0x80108693
801017a8:	e8 cc ed ff ff       	call   80100579 <panic>
}
801017ad:	c9                   	leave
801017ae:	c3                   	ret

801017af <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
801017af:	55                   	push   %ebp
801017b0:	89 e5                	mov    %esp,%ebp
801017b2:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801017b5:	8b 45 08             	mov    0x8(%ebp),%eax
801017b8:	8b 40 04             	mov    0x4(%eax),%eax
801017bb:	c1 e8 03             	shr    $0x3,%eax
801017be:	89 c2                	mov    %eax,%edx
801017c0:	a1 b4 01 11 80       	mov    0x801101b4,%eax
801017c5:	01 c2                	add    %eax,%edx
801017c7:	8b 45 08             	mov    0x8(%ebp),%eax
801017ca:	8b 00                	mov    (%eax),%eax
801017cc:	83 ec 08             	sub    $0x8,%esp
801017cf:	52                   	push   %edx
801017d0:	50                   	push   %eax
801017d1:	e8 e1 e9 ff ff       	call   801001b7 <bread>
801017d6:	83 c4 10             	add    $0x10,%esp
801017d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801017dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017df:	8d 50 18             	lea    0x18(%eax),%edx
801017e2:	8b 45 08             	mov    0x8(%ebp),%eax
801017e5:	8b 40 04             	mov    0x4(%eax),%eax
801017e8:	83 e0 07             	and    $0x7,%eax
801017eb:	c1 e0 06             	shl    $0x6,%eax
801017ee:	01 d0                	add    %edx,%eax
801017f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801017f3:	8b 45 08             	mov    0x8(%ebp),%eax
801017f6:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801017fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017fd:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101800:	8b 45 08             	mov    0x8(%ebp),%eax
80101803:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101807:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010180a:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010180e:	8b 45 08             	mov    0x8(%ebp),%eax
80101811:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101815:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101818:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010181c:	8b 45 08             	mov    0x8(%ebp),%eax
8010181f:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101823:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101826:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010182a:	8b 45 08             	mov    0x8(%ebp),%eax
8010182d:	8b 50 18             	mov    0x18(%eax),%edx
80101830:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101833:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101836:	8b 45 08             	mov    0x8(%ebp),%eax
80101839:	8d 50 1c             	lea    0x1c(%eax),%edx
8010183c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010183f:	83 c0 0c             	add    $0xc,%eax
80101842:	83 ec 04             	sub    $0x4,%esp
80101845:	6a 34                	push   $0x34
80101847:	52                   	push   %edx
80101848:	50                   	push   %eax
80101849:	e8 1a 3b 00 00       	call   80105368 <memmove>
8010184e:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101851:	83 ec 0c             	sub    $0xc,%esp
80101854:	ff 75 f4             	push   -0xc(%ebp)
80101857:	e8 33 1f 00 00       	call   8010378f <log_write>
8010185c:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010185f:	83 ec 0c             	sub    $0xc,%esp
80101862:	ff 75 f4             	push   -0xc(%ebp)
80101865:	e8 c5 e9 ff ff       	call   8010022f <brelse>
8010186a:	83 c4 10             	add    $0x10,%esp
}
8010186d:	90                   	nop
8010186e:	c9                   	leave
8010186f:	c3                   	ret

80101870 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101870:	55                   	push   %ebp
80101871:	89 e5                	mov    %esp,%ebp
80101873:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101876:	83 ec 0c             	sub    $0xc,%esp
80101879:	68 c0 01 11 80       	push   $0x801101c0
8010187e:	e8 c2 37 00 00       	call   80105045 <acquire>
80101883:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101886:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010188d:	c7 45 f4 f4 01 11 80 	movl   $0x801101f4,-0xc(%ebp)
80101894:	eb 5d                	jmp    801018f3 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101896:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101899:	8b 40 08             	mov    0x8(%eax),%eax
8010189c:	85 c0                	test   %eax,%eax
8010189e:	7e 39                	jle    801018d9 <iget+0x69>
801018a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a3:	8b 00                	mov    (%eax),%eax
801018a5:	39 45 08             	cmp    %eax,0x8(%ebp)
801018a8:	75 2f                	jne    801018d9 <iget+0x69>
801018aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ad:	8b 40 04             	mov    0x4(%eax),%eax
801018b0:	39 45 0c             	cmp    %eax,0xc(%ebp)
801018b3:	75 24                	jne    801018d9 <iget+0x69>
      ip->ref++;
801018b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b8:	8b 40 08             	mov    0x8(%eax),%eax
801018bb:	8d 50 01             	lea    0x1(%eax),%edx
801018be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018c1:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801018c4:	83 ec 0c             	sub    $0xc,%esp
801018c7:	68 c0 01 11 80       	push   $0x801101c0
801018cc:	e8 db 37 00 00       	call   801050ac <release>
801018d1:	83 c4 10             	add    $0x10,%esp
      return ip;
801018d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018d7:	eb 74                	jmp    8010194d <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801018d9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018dd:	75 10                	jne    801018ef <iget+0x7f>
801018df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018e2:	8b 40 08             	mov    0x8(%eax),%eax
801018e5:	85 c0                	test   %eax,%eax
801018e7:	75 06                	jne    801018ef <iget+0x7f>
      empty = ip;
801018e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ec:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018ef:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801018f3:	81 7d f4 94 11 11 80 	cmpl   $0x80111194,-0xc(%ebp)
801018fa:	72 9a                	jb     80101896 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801018fc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101900:	75 0d                	jne    8010190f <iget+0x9f>
    panic("iget: no inodes");
80101902:	83 ec 0c             	sub    $0xc,%esp
80101905:	68 a5 86 10 80       	push   $0x801086a5
8010190a:	e8 6a ec ff ff       	call   80100579 <panic>

  ip = empty;
8010190f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101912:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101915:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101918:	8b 55 08             	mov    0x8(%ebp),%edx
8010191b:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010191d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101920:	8b 55 0c             	mov    0xc(%ebp),%edx
80101923:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101926:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101929:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
80101930:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101933:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
8010193a:	83 ec 0c             	sub    $0xc,%esp
8010193d:	68 c0 01 11 80       	push   $0x801101c0
80101942:	e8 65 37 00 00       	call   801050ac <release>
80101947:	83 c4 10             	add    $0x10,%esp

  return ip;
8010194a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010194d:	c9                   	leave
8010194e:	c3                   	ret

8010194f <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
8010194f:	55                   	push   %ebp
80101950:	89 e5                	mov    %esp,%ebp
80101952:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101955:	83 ec 0c             	sub    $0xc,%esp
80101958:	68 c0 01 11 80       	push   $0x801101c0
8010195d:	e8 e3 36 00 00       	call   80105045 <acquire>
80101962:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101965:	8b 45 08             	mov    0x8(%ebp),%eax
80101968:	8b 40 08             	mov    0x8(%eax),%eax
8010196b:	8d 50 01             	lea    0x1(%eax),%edx
8010196e:	8b 45 08             	mov    0x8(%ebp),%eax
80101971:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101974:	83 ec 0c             	sub    $0xc,%esp
80101977:	68 c0 01 11 80       	push   $0x801101c0
8010197c:	e8 2b 37 00 00       	call   801050ac <release>
80101981:	83 c4 10             	add    $0x10,%esp
  return ip;
80101984:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101987:	c9                   	leave
80101988:	c3                   	ret

80101989 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101989:	55                   	push   %ebp
8010198a:	89 e5                	mov    %esp,%ebp
8010198c:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
8010198f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101993:	74 0a                	je     8010199f <ilock+0x16>
80101995:	8b 45 08             	mov    0x8(%ebp),%eax
80101998:	8b 40 08             	mov    0x8(%eax),%eax
8010199b:	85 c0                	test   %eax,%eax
8010199d:	7f 0d                	jg     801019ac <ilock+0x23>
    panic("ilock");
8010199f:	83 ec 0c             	sub    $0xc,%esp
801019a2:	68 b5 86 10 80       	push   $0x801086b5
801019a7:	e8 cd eb ff ff       	call   80100579 <panic>

  acquire(&icache.lock);
801019ac:	83 ec 0c             	sub    $0xc,%esp
801019af:	68 c0 01 11 80       	push   $0x801101c0
801019b4:	e8 8c 36 00 00       	call   80105045 <acquire>
801019b9:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
801019bc:	eb 13                	jmp    801019d1 <ilock+0x48>
    sleep(ip, &icache.lock);
801019be:	83 ec 08             	sub    $0x8,%esp
801019c1:	68 c0 01 11 80       	push   $0x801101c0
801019c6:	ff 75 08             	push   0x8(%ebp)
801019c9:	e8 7c 33 00 00       	call   80104d4a <sleep>
801019ce:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
801019d1:	8b 45 08             	mov    0x8(%ebp),%eax
801019d4:	8b 40 0c             	mov    0xc(%eax),%eax
801019d7:	83 e0 01             	and    $0x1,%eax
801019da:	85 c0                	test   %eax,%eax
801019dc:	75 e0                	jne    801019be <ilock+0x35>
  ip->flags |= I_BUSY;
801019de:	8b 45 08             	mov    0x8(%ebp),%eax
801019e1:	8b 40 0c             	mov    0xc(%eax),%eax
801019e4:	83 c8 01             	or     $0x1,%eax
801019e7:	89 c2                	mov    %eax,%edx
801019e9:	8b 45 08             	mov    0x8(%ebp),%eax
801019ec:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801019ef:	83 ec 0c             	sub    $0xc,%esp
801019f2:	68 c0 01 11 80       	push   $0x801101c0
801019f7:	e8 b0 36 00 00       	call   801050ac <release>
801019fc:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
801019ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101a02:	8b 40 0c             	mov    0xc(%eax),%eax
80101a05:	83 e0 02             	and    $0x2,%eax
80101a08:	85 c0                	test   %eax,%eax
80101a0a:	0f 85 d4 00 00 00    	jne    80101ae4 <ilock+0x15b>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a10:	8b 45 08             	mov    0x8(%ebp),%eax
80101a13:	8b 40 04             	mov    0x4(%eax),%eax
80101a16:	c1 e8 03             	shr    $0x3,%eax
80101a19:	89 c2                	mov    %eax,%edx
80101a1b:	a1 b4 01 11 80       	mov    0x801101b4,%eax
80101a20:	01 c2                	add    %eax,%edx
80101a22:	8b 45 08             	mov    0x8(%ebp),%eax
80101a25:	8b 00                	mov    (%eax),%eax
80101a27:	83 ec 08             	sub    $0x8,%esp
80101a2a:	52                   	push   %edx
80101a2b:	50                   	push   %eax
80101a2c:	e8 86 e7 ff ff       	call   801001b7 <bread>
80101a31:	83 c4 10             	add    $0x10,%esp
80101a34:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a37:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a3a:	8d 50 18             	lea    0x18(%eax),%edx
80101a3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a40:	8b 40 04             	mov    0x4(%eax),%eax
80101a43:	83 e0 07             	and    $0x7,%eax
80101a46:	c1 e0 06             	shl    $0x6,%eax
80101a49:	01 d0                	add    %edx,%eax
80101a4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a51:	0f b7 10             	movzwl (%eax),%edx
80101a54:	8b 45 08             	mov    0x8(%ebp),%eax
80101a57:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101a5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a5e:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a62:	8b 45 08             	mov    0x8(%ebp),%eax
80101a65:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101a69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a6c:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a70:	8b 45 08             	mov    0x8(%ebp),%eax
80101a73:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101a77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a7a:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a81:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101a85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a88:	8b 50 08             	mov    0x8(%eax),%edx
80101a8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8e:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a91:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a94:	8d 50 0c             	lea    0xc(%eax),%edx
80101a97:	8b 45 08             	mov    0x8(%ebp),%eax
80101a9a:	83 c0 1c             	add    $0x1c,%eax
80101a9d:	83 ec 04             	sub    $0x4,%esp
80101aa0:	6a 34                	push   $0x34
80101aa2:	52                   	push   %edx
80101aa3:	50                   	push   %eax
80101aa4:	e8 bf 38 00 00       	call   80105368 <memmove>
80101aa9:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101aac:	83 ec 0c             	sub    $0xc,%esp
80101aaf:	ff 75 f4             	push   -0xc(%ebp)
80101ab2:	e8 78 e7 ff ff       	call   8010022f <brelse>
80101ab7:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101aba:	8b 45 08             	mov    0x8(%ebp),%eax
80101abd:	8b 40 0c             	mov    0xc(%eax),%eax
80101ac0:	83 c8 02             	or     $0x2,%eax
80101ac3:	89 c2                	mov    %eax,%edx
80101ac5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac8:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101acb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ace:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ad2:	66 85 c0             	test   %ax,%ax
80101ad5:	75 0d                	jne    80101ae4 <ilock+0x15b>
      panic("ilock: no type");
80101ad7:	83 ec 0c             	sub    $0xc,%esp
80101ada:	68 bb 86 10 80       	push   $0x801086bb
80101adf:	e8 95 ea ff ff       	call   80100579 <panic>
  }
}
80101ae4:	90                   	nop
80101ae5:	c9                   	leave
80101ae6:	c3                   	ret

80101ae7 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101ae7:	55                   	push   %ebp
80101ae8:	89 e5                	mov    %esp,%ebp
80101aea:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101aed:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101af1:	74 17                	je     80101b0a <iunlock+0x23>
80101af3:	8b 45 08             	mov    0x8(%ebp),%eax
80101af6:	8b 40 0c             	mov    0xc(%eax),%eax
80101af9:	83 e0 01             	and    $0x1,%eax
80101afc:	85 c0                	test   %eax,%eax
80101afe:	74 0a                	je     80101b0a <iunlock+0x23>
80101b00:	8b 45 08             	mov    0x8(%ebp),%eax
80101b03:	8b 40 08             	mov    0x8(%eax),%eax
80101b06:	85 c0                	test   %eax,%eax
80101b08:	7f 0d                	jg     80101b17 <iunlock+0x30>
    panic("iunlock");
80101b0a:	83 ec 0c             	sub    $0xc,%esp
80101b0d:	68 ca 86 10 80       	push   $0x801086ca
80101b12:	e8 62 ea ff ff       	call   80100579 <panic>

  acquire(&icache.lock);
80101b17:	83 ec 0c             	sub    $0xc,%esp
80101b1a:	68 c0 01 11 80       	push   $0x801101c0
80101b1f:	e8 21 35 00 00       	call   80105045 <acquire>
80101b24:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101b27:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2a:	8b 40 0c             	mov    0xc(%eax),%eax
80101b2d:	83 e0 fe             	and    $0xfffffffe,%eax
80101b30:	89 c2                	mov    %eax,%edx
80101b32:	8b 45 08             	mov    0x8(%ebp),%eax
80101b35:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101b38:	83 ec 0c             	sub    $0xc,%esp
80101b3b:	ff 75 08             	push   0x8(%ebp)
80101b3e:	e8 f3 32 00 00       	call   80104e36 <wakeup>
80101b43:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101b46:	83 ec 0c             	sub    $0xc,%esp
80101b49:	68 c0 01 11 80       	push   $0x801101c0
80101b4e:	e8 59 35 00 00       	call   801050ac <release>
80101b53:	83 c4 10             	add    $0x10,%esp
}
80101b56:	90                   	nop
80101b57:	c9                   	leave
80101b58:	c3                   	ret

80101b59 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b59:	55                   	push   %ebp
80101b5a:	89 e5                	mov    %esp,%ebp
80101b5c:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101b5f:	83 ec 0c             	sub    $0xc,%esp
80101b62:	68 c0 01 11 80       	push   $0x801101c0
80101b67:	e8 d9 34 00 00       	call   80105045 <acquire>
80101b6c:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101b6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b72:	8b 40 08             	mov    0x8(%eax),%eax
80101b75:	83 f8 01             	cmp    $0x1,%eax
80101b78:	0f 85 a9 00 00 00    	jne    80101c27 <iput+0xce>
80101b7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b81:	8b 40 0c             	mov    0xc(%eax),%eax
80101b84:	83 e0 02             	and    $0x2,%eax
80101b87:	85 c0                	test   %eax,%eax
80101b89:	0f 84 98 00 00 00    	je     80101c27 <iput+0xce>
80101b8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b92:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101b96:	66 85 c0             	test   %ax,%ax
80101b99:	0f 85 88 00 00 00    	jne    80101c27 <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101b9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba2:	8b 40 0c             	mov    0xc(%eax),%eax
80101ba5:	83 e0 01             	and    $0x1,%eax
80101ba8:	85 c0                	test   %eax,%eax
80101baa:	74 0d                	je     80101bb9 <iput+0x60>
      panic("iput busy");
80101bac:	83 ec 0c             	sub    $0xc,%esp
80101baf:	68 d2 86 10 80       	push   $0x801086d2
80101bb4:	e8 c0 e9 ff ff       	call   80100579 <panic>
    ip->flags |= I_BUSY;
80101bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bbc:	8b 40 0c             	mov    0xc(%eax),%eax
80101bbf:	83 c8 01             	or     $0x1,%eax
80101bc2:	89 c2                	mov    %eax,%edx
80101bc4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc7:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101bca:	83 ec 0c             	sub    $0xc,%esp
80101bcd:	68 c0 01 11 80       	push   $0x801101c0
80101bd2:	e8 d5 34 00 00       	call   801050ac <release>
80101bd7:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101bda:	83 ec 0c             	sub    $0xc,%esp
80101bdd:	ff 75 08             	push   0x8(%ebp)
80101be0:	e8 a3 01 00 00       	call   80101d88 <itrunc>
80101be5:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101be8:	8b 45 08             	mov    0x8(%ebp),%eax
80101beb:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101bf1:	83 ec 0c             	sub    $0xc,%esp
80101bf4:	ff 75 08             	push   0x8(%ebp)
80101bf7:	e8 b3 fb ff ff       	call   801017af <iupdate>
80101bfc:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101bff:	83 ec 0c             	sub    $0xc,%esp
80101c02:	68 c0 01 11 80       	push   $0x801101c0
80101c07:	e8 39 34 00 00       	call   80105045 <acquire>
80101c0c:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101c0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101c12:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101c19:	83 ec 0c             	sub    $0xc,%esp
80101c1c:	ff 75 08             	push   0x8(%ebp)
80101c1f:	e8 12 32 00 00       	call   80104e36 <wakeup>
80101c24:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101c27:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2a:	8b 40 08             	mov    0x8(%eax),%eax
80101c2d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c30:	8b 45 08             	mov    0x8(%ebp),%eax
80101c33:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c36:	83 ec 0c             	sub    $0xc,%esp
80101c39:	68 c0 01 11 80       	push   $0x801101c0
80101c3e:	e8 69 34 00 00       	call   801050ac <release>
80101c43:	83 c4 10             	add    $0x10,%esp
}
80101c46:	90                   	nop
80101c47:	c9                   	leave
80101c48:	c3                   	ret

80101c49 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c49:	55                   	push   %ebp
80101c4a:	89 e5                	mov    %esp,%ebp
80101c4c:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c4f:	83 ec 0c             	sub    $0xc,%esp
80101c52:	ff 75 08             	push   0x8(%ebp)
80101c55:	e8 8d fe ff ff       	call   80101ae7 <iunlock>
80101c5a:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c5d:	83 ec 0c             	sub    $0xc,%esp
80101c60:	ff 75 08             	push   0x8(%ebp)
80101c63:	e8 f1 fe ff ff       	call   80101b59 <iput>
80101c68:	83 c4 10             	add    $0x10,%esp
}
80101c6b:	90                   	nop
80101c6c:	c9                   	leave
80101c6d:	c3                   	ret

80101c6e <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c6e:	55                   	push   %ebp
80101c6f:	89 e5                	mov    %esp,%ebp
80101c71:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c74:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c78:	77 42                	ja     80101cbc <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7d:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c80:	83 c2 04             	add    $0x4,%edx
80101c83:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c87:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c8a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c8e:	75 24                	jne    80101cb4 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c90:	8b 45 08             	mov    0x8(%ebp),%eax
80101c93:	8b 00                	mov    (%eax),%eax
80101c95:	83 ec 0c             	sub    $0xc,%esp
80101c98:	50                   	push   %eax
80101c99:	e8 ad f7 ff ff       	call   8010144b <balloc>
80101c9e:	83 c4 10             	add    $0x10,%esp
80101ca1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca7:	8b 55 0c             	mov    0xc(%ebp),%edx
80101caa:	8d 4a 04             	lea    0x4(%edx),%ecx
80101cad:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cb0:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cb7:	e9 ca 00 00 00       	jmp    80101d86 <bmap+0x118>
  }
  bn -= NDIRECT;
80101cbc:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101cc0:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101cc4:	0f 87 af 00 00 00    	ja     80101d79 <bmap+0x10b>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101cca:	8b 45 08             	mov    0x8(%ebp),%eax
80101ccd:	8b 40 4c             	mov    0x4c(%eax),%eax
80101cd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cd3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cd7:	75 1d                	jne    80101cf6 <bmap+0x88>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cd9:	8b 45 08             	mov    0x8(%ebp),%eax
80101cdc:	8b 00                	mov    (%eax),%eax
80101cde:	83 ec 0c             	sub    $0xc,%esp
80101ce1:	50                   	push   %eax
80101ce2:	e8 64 f7 ff ff       	call   8010144b <balloc>
80101ce7:	83 c4 10             	add    $0x10,%esp
80101cea:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ced:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cf3:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101cf6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf9:	8b 00                	mov    (%eax),%eax
80101cfb:	83 ec 08             	sub    $0x8,%esp
80101cfe:	ff 75 f4             	push   -0xc(%ebp)
80101d01:	50                   	push   %eax
80101d02:	e8 b0 e4 ff ff       	call   801001b7 <bread>
80101d07:	83 c4 10             	add    $0x10,%esp
80101d0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d10:	83 c0 18             	add    $0x18,%eax
80101d13:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d16:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d19:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d20:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d23:	01 d0                	add    %edx,%eax
80101d25:	8b 00                	mov    (%eax),%eax
80101d27:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d2a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d2e:	75 36                	jne    80101d66 <bmap+0xf8>
      a[bn] = addr = balloc(ip->dev);
80101d30:	8b 45 08             	mov    0x8(%ebp),%eax
80101d33:	8b 00                	mov    (%eax),%eax
80101d35:	83 ec 0c             	sub    $0xc,%esp
80101d38:	50                   	push   %eax
80101d39:	e8 0d f7 ff ff       	call   8010144b <balloc>
80101d3e:	83 c4 10             	add    $0x10,%esp
80101d41:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d44:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d47:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d4e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d51:	01 c2                	add    %eax,%edx
80101d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d56:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d58:	83 ec 0c             	sub    $0xc,%esp
80101d5b:	ff 75 f0             	push   -0x10(%ebp)
80101d5e:	e8 2c 1a 00 00       	call   8010378f <log_write>
80101d63:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d66:	83 ec 0c             	sub    $0xc,%esp
80101d69:	ff 75 f0             	push   -0x10(%ebp)
80101d6c:	e8 be e4 ff ff       	call   8010022f <brelse>
80101d71:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d77:	eb 0d                	jmp    80101d86 <bmap+0x118>
  }

  panic("bmap: out of range");
80101d79:	83 ec 0c             	sub    $0xc,%esp
80101d7c:	68 dc 86 10 80       	push   $0x801086dc
80101d81:	e8 f3 e7 ff ff       	call   80100579 <panic>
}
80101d86:	c9                   	leave
80101d87:	c3                   	ret

80101d88 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d88:	55                   	push   %ebp
80101d89:	89 e5                	mov    %esp,%ebp
80101d8b:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d8e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d95:	eb 45                	jmp    80101ddc <itrunc+0x54>
    if(ip->addrs[i]){
80101d97:	8b 45 08             	mov    0x8(%ebp),%eax
80101d9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d9d:	83 c2 04             	add    $0x4,%edx
80101da0:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101da4:	85 c0                	test   %eax,%eax
80101da6:	74 30                	je     80101dd8 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101da8:	8b 45 08             	mov    0x8(%ebp),%eax
80101dab:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dae:	83 c2 04             	add    $0x4,%edx
80101db1:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101db5:	8b 55 08             	mov    0x8(%ebp),%edx
80101db8:	8b 12                	mov    (%edx),%edx
80101dba:	83 ec 08             	sub    $0x8,%esp
80101dbd:	50                   	push   %eax
80101dbe:	52                   	push   %edx
80101dbf:	e8 ca f7 ff ff       	call   8010158e <bfree>
80101dc4:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101dc7:	8b 45 08             	mov    0x8(%ebp),%eax
80101dca:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dcd:	83 c2 04             	add    $0x4,%edx
80101dd0:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101dd7:	00 
  for(i = 0; i < NDIRECT; i++){
80101dd8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101ddc:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101de0:	7e b5                	jle    80101d97 <itrunc+0xf>
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101de2:	8b 45 08             	mov    0x8(%ebp),%eax
80101de5:	8b 40 4c             	mov    0x4c(%eax),%eax
80101de8:	85 c0                	test   %eax,%eax
80101dea:	0f 84 a1 00 00 00    	je     80101e91 <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101df0:	8b 45 08             	mov    0x8(%ebp),%eax
80101df3:	8b 50 4c             	mov    0x4c(%eax),%edx
80101df6:	8b 45 08             	mov    0x8(%ebp),%eax
80101df9:	8b 00                	mov    (%eax),%eax
80101dfb:	83 ec 08             	sub    $0x8,%esp
80101dfe:	52                   	push   %edx
80101dff:	50                   	push   %eax
80101e00:	e8 b2 e3 ff ff       	call   801001b7 <bread>
80101e05:	83 c4 10             	add    $0x10,%esp
80101e08:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e0e:	83 c0 18             	add    $0x18,%eax
80101e11:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e14:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e1b:	eb 3c                	jmp    80101e59 <itrunc+0xd1>
      if(a[j])
80101e1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e20:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e27:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e2a:	01 d0                	add    %edx,%eax
80101e2c:	8b 00                	mov    (%eax),%eax
80101e2e:	85 c0                	test   %eax,%eax
80101e30:	74 23                	je     80101e55 <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101e32:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e35:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e3c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e3f:	01 d0                	add    %edx,%eax
80101e41:	8b 00                	mov    (%eax),%eax
80101e43:	8b 55 08             	mov    0x8(%ebp),%edx
80101e46:	8b 12                	mov    (%edx),%edx
80101e48:	83 ec 08             	sub    $0x8,%esp
80101e4b:	50                   	push   %eax
80101e4c:	52                   	push   %edx
80101e4d:	e8 3c f7 ff ff       	call   8010158e <bfree>
80101e52:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e55:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e5c:	83 f8 7f             	cmp    $0x7f,%eax
80101e5f:	76 bc                	jbe    80101e1d <itrunc+0x95>
    }
    brelse(bp);
80101e61:	83 ec 0c             	sub    $0xc,%esp
80101e64:	ff 75 ec             	push   -0x14(%ebp)
80101e67:	e8 c3 e3 ff ff       	call   8010022f <brelse>
80101e6c:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e72:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e75:	8b 55 08             	mov    0x8(%ebp),%edx
80101e78:	8b 12                	mov    (%edx),%edx
80101e7a:	83 ec 08             	sub    $0x8,%esp
80101e7d:	50                   	push   %eax
80101e7e:	52                   	push   %edx
80101e7f:	e8 0a f7 ff ff       	call   8010158e <bfree>
80101e84:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e87:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8a:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101e91:	8b 45 08             	mov    0x8(%ebp),%eax
80101e94:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101e9b:	83 ec 0c             	sub    $0xc,%esp
80101e9e:	ff 75 08             	push   0x8(%ebp)
80101ea1:	e8 09 f9 ff ff       	call   801017af <iupdate>
80101ea6:	83 c4 10             	add    $0x10,%esp
}
80101ea9:	90                   	nop
80101eaa:	c9                   	leave
80101eab:	c3                   	ret

80101eac <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101eac:	55                   	push   %ebp
80101ead:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101eaf:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb2:	8b 00                	mov    (%eax),%eax
80101eb4:	89 c2                	mov    %eax,%edx
80101eb6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb9:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ebc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebf:	8b 50 04             	mov    0x4(%eax),%edx
80101ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec5:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ecb:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101ecf:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed2:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ed5:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed8:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101edc:	8b 45 0c             	mov    0xc(%ebp),%eax
80101edf:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ee3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee6:	8b 50 18             	mov    0x18(%eax),%edx
80101ee9:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eec:	89 50 10             	mov    %edx,0x10(%eax)
}
80101eef:	90                   	nop
80101ef0:	5d                   	pop    %ebp
80101ef1:	c3                   	ret

80101ef2 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ef2:	55                   	push   %ebp
80101ef3:	89 e5                	mov    %esp,%ebp
80101ef5:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ef8:	8b 45 08             	mov    0x8(%ebp),%eax
80101efb:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101eff:	66 83 f8 03          	cmp    $0x3,%ax
80101f03:	75 5c                	jne    80101f61 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f05:	8b 45 08             	mov    0x8(%ebp),%eax
80101f08:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f0c:	66 85 c0             	test   %ax,%ax
80101f0f:	78 20                	js     80101f31 <readi+0x3f>
80101f11:	8b 45 08             	mov    0x8(%ebp),%eax
80101f14:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f18:	66 83 f8 09          	cmp    $0x9,%ax
80101f1c:	7f 13                	jg     80101f31 <readi+0x3f>
80101f1e:	8b 45 08             	mov    0x8(%ebp),%eax
80101f21:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f25:	98                   	cwtl
80101f26:	8b 04 c5 a0 f7 10 80 	mov    -0x7fef0860(,%eax,8),%eax
80101f2d:	85 c0                	test   %eax,%eax
80101f2f:	75 0a                	jne    80101f3b <readi+0x49>
      return -1;
80101f31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f36:	e9 0a 01 00 00       	jmp    80102045 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3e:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f42:	98                   	cwtl
80101f43:	8b 04 c5 a0 f7 10 80 	mov    -0x7fef0860(,%eax,8),%eax
80101f4a:	8b 55 14             	mov    0x14(%ebp),%edx
80101f4d:	83 ec 04             	sub    $0x4,%esp
80101f50:	52                   	push   %edx
80101f51:	ff 75 0c             	push   0xc(%ebp)
80101f54:	ff 75 08             	push   0x8(%ebp)
80101f57:	ff d0                	call   *%eax
80101f59:	83 c4 10             	add    $0x10,%esp
80101f5c:	e9 e4 00 00 00       	jmp    80102045 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f61:	8b 45 08             	mov    0x8(%ebp),%eax
80101f64:	8b 40 18             	mov    0x18(%eax),%eax
80101f67:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f6a:	72 0d                	jb     80101f79 <readi+0x87>
80101f6c:	8b 55 10             	mov    0x10(%ebp),%edx
80101f6f:	8b 45 14             	mov    0x14(%ebp),%eax
80101f72:	01 d0                	add    %edx,%eax
80101f74:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f77:	73 0a                	jae    80101f83 <readi+0x91>
    return -1;
80101f79:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f7e:	e9 c2 00 00 00       	jmp    80102045 <readi+0x153>
  if(off + n > ip->size)
80101f83:	8b 55 10             	mov    0x10(%ebp),%edx
80101f86:	8b 45 14             	mov    0x14(%ebp),%eax
80101f89:	01 c2                	add    %eax,%edx
80101f8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8e:	8b 40 18             	mov    0x18(%eax),%eax
80101f91:	39 d0                	cmp    %edx,%eax
80101f93:	73 0c                	jae    80101fa1 <readi+0xaf>
    n = ip->size - off;
80101f95:	8b 45 08             	mov    0x8(%ebp),%eax
80101f98:	8b 40 18             	mov    0x18(%eax),%eax
80101f9b:	2b 45 10             	sub    0x10(%ebp),%eax
80101f9e:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101fa1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101fa8:	e9 89 00 00 00       	jmp    80102036 <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101fad:	8b 45 10             	mov    0x10(%ebp),%eax
80101fb0:	c1 e8 09             	shr    $0x9,%eax
80101fb3:	83 ec 08             	sub    $0x8,%esp
80101fb6:	50                   	push   %eax
80101fb7:	ff 75 08             	push   0x8(%ebp)
80101fba:	e8 af fc ff ff       	call   80101c6e <bmap>
80101fbf:	83 c4 10             	add    $0x10,%esp
80101fc2:	8b 55 08             	mov    0x8(%ebp),%edx
80101fc5:	8b 12                	mov    (%edx),%edx
80101fc7:	83 ec 08             	sub    $0x8,%esp
80101fca:	50                   	push   %eax
80101fcb:	52                   	push   %edx
80101fcc:	e8 e6 e1 ff ff       	call   801001b7 <bread>
80101fd1:	83 c4 10             	add    $0x10,%esp
80101fd4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fd7:	8b 45 10             	mov    0x10(%ebp),%eax
80101fda:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fdf:	ba 00 02 00 00       	mov    $0x200,%edx
80101fe4:	29 c2                	sub    %eax,%edx
80101fe6:	8b 45 14             	mov    0x14(%ebp),%eax
80101fe9:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fec:	39 c2                	cmp    %eax,%edx
80101fee:	0f 46 c2             	cmovbe %edx,%eax
80101ff1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101ff4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ff7:	8d 50 18             	lea    0x18(%eax),%edx
80101ffa:	8b 45 10             	mov    0x10(%ebp),%eax
80101ffd:	25 ff 01 00 00       	and    $0x1ff,%eax
80102002:	01 d0                	add    %edx,%eax
80102004:	83 ec 04             	sub    $0x4,%esp
80102007:	ff 75 ec             	push   -0x14(%ebp)
8010200a:	50                   	push   %eax
8010200b:	ff 75 0c             	push   0xc(%ebp)
8010200e:	e8 55 33 00 00       	call   80105368 <memmove>
80102013:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102016:	83 ec 0c             	sub    $0xc,%esp
80102019:	ff 75 f0             	push   -0x10(%ebp)
8010201c:	e8 0e e2 ff ff       	call   8010022f <brelse>
80102021:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102024:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102027:	01 45 f4             	add    %eax,-0xc(%ebp)
8010202a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010202d:	01 45 10             	add    %eax,0x10(%ebp)
80102030:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102033:	01 45 0c             	add    %eax,0xc(%ebp)
80102036:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102039:	3b 45 14             	cmp    0x14(%ebp),%eax
8010203c:	0f 82 6b ff ff ff    	jb     80101fad <readi+0xbb>
  }
  return n;
80102042:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102045:	c9                   	leave
80102046:	c3                   	ret

80102047 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102047:	55                   	push   %ebp
80102048:	89 e5                	mov    %esp,%ebp
8010204a:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010204d:	8b 45 08             	mov    0x8(%ebp),%eax
80102050:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102054:	66 83 f8 03          	cmp    $0x3,%ax
80102058:	75 5c                	jne    801020b6 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
8010205a:	8b 45 08             	mov    0x8(%ebp),%eax
8010205d:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102061:	66 85 c0             	test   %ax,%ax
80102064:	78 20                	js     80102086 <writei+0x3f>
80102066:	8b 45 08             	mov    0x8(%ebp),%eax
80102069:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010206d:	66 83 f8 09          	cmp    $0x9,%ax
80102071:	7f 13                	jg     80102086 <writei+0x3f>
80102073:	8b 45 08             	mov    0x8(%ebp),%eax
80102076:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010207a:	98                   	cwtl
8010207b:	8b 04 c5 a4 f7 10 80 	mov    -0x7fef085c(,%eax,8),%eax
80102082:	85 c0                	test   %eax,%eax
80102084:	75 0a                	jne    80102090 <writei+0x49>
      return -1;
80102086:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010208b:	e9 3b 01 00 00       	jmp    801021cb <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
80102090:	8b 45 08             	mov    0x8(%ebp),%eax
80102093:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102097:	98                   	cwtl
80102098:	8b 04 c5 a4 f7 10 80 	mov    -0x7fef085c(,%eax,8),%eax
8010209f:	8b 55 14             	mov    0x14(%ebp),%edx
801020a2:	83 ec 04             	sub    $0x4,%esp
801020a5:	52                   	push   %edx
801020a6:	ff 75 0c             	push   0xc(%ebp)
801020a9:	ff 75 08             	push   0x8(%ebp)
801020ac:	ff d0                	call   *%eax
801020ae:	83 c4 10             	add    $0x10,%esp
801020b1:	e9 15 01 00 00       	jmp    801021cb <writei+0x184>
  }

  if(off > ip->size || off + n < off)
801020b6:	8b 45 08             	mov    0x8(%ebp),%eax
801020b9:	8b 40 18             	mov    0x18(%eax),%eax
801020bc:	3b 45 10             	cmp    0x10(%ebp),%eax
801020bf:	72 0d                	jb     801020ce <writei+0x87>
801020c1:	8b 55 10             	mov    0x10(%ebp),%edx
801020c4:	8b 45 14             	mov    0x14(%ebp),%eax
801020c7:	01 d0                	add    %edx,%eax
801020c9:	3b 45 10             	cmp    0x10(%ebp),%eax
801020cc:	73 0a                	jae    801020d8 <writei+0x91>
    return -1;
801020ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d3:	e9 f3 00 00 00       	jmp    801021cb <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020d8:	8b 55 10             	mov    0x10(%ebp),%edx
801020db:	8b 45 14             	mov    0x14(%ebp),%eax
801020de:	01 d0                	add    %edx,%eax
801020e0:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020e5:	76 0a                	jbe    801020f1 <writei+0xaa>
    return -1;
801020e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020ec:	e9 da 00 00 00       	jmp    801021cb <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020f1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020f8:	e9 97 00 00 00       	jmp    80102194 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020fd:	8b 45 10             	mov    0x10(%ebp),%eax
80102100:	c1 e8 09             	shr    $0x9,%eax
80102103:	83 ec 08             	sub    $0x8,%esp
80102106:	50                   	push   %eax
80102107:	ff 75 08             	push   0x8(%ebp)
8010210a:	e8 5f fb ff ff       	call   80101c6e <bmap>
8010210f:	83 c4 10             	add    $0x10,%esp
80102112:	8b 55 08             	mov    0x8(%ebp),%edx
80102115:	8b 12                	mov    (%edx),%edx
80102117:	83 ec 08             	sub    $0x8,%esp
8010211a:	50                   	push   %eax
8010211b:	52                   	push   %edx
8010211c:	e8 96 e0 ff ff       	call   801001b7 <bread>
80102121:	83 c4 10             	add    $0x10,%esp
80102124:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102127:	8b 45 10             	mov    0x10(%ebp),%eax
8010212a:	25 ff 01 00 00       	and    $0x1ff,%eax
8010212f:	ba 00 02 00 00       	mov    $0x200,%edx
80102134:	29 c2                	sub    %eax,%edx
80102136:	8b 45 14             	mov    0x14(%ebp),%eax
80102139:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010213c:	39 c2                	cmp    %eax,%edx
8010213e:	0f 46 c2             	cmovbe %edx,%eax
80102141:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102144:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102147:	8d 50 18             	lea    0x18(%eax),%edx
8010214a:	8b 45 10             	mov    0x10(%ebp),%eax
8010214d:	25 ff 01 00 00       	and    $0x1ff,%eax
80102152:	01 d0                	add    %edx,%eax
80102154:	83 ec 04             	sub    $0x4,%esp
80102157:	ff 75 ec             	push   -0x14(%ebp)
8010215a:	ff 75 0c             	push   0xc(%ebp)
8010215d:	50                   	push   %eax
8010215e:	e8 05 32 00 00       	call   80105368 <memmove>
80102163:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102166:	83 ec 0c             	sub    $0xc,%esp
80102169:	ff 75 f0             	push   -0x10(%ebp)
8010216c:	e8 1e 16 00 00       	call   8010378f <log_write>
80102171:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102174:	83 ec 0c             	sub    $0xc,%esp
80102177:	ff 75 f0             	push   -0x10(%ebp)
8010217a:	e8 b0 e0 ff ff       	call   8010022f <brelse>
8010217f:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102182:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102185:	01 45 f4             	add    %eax,-0xc(%ebp)
80102188:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010218b:	01 45 10             	add    %eax,0x10(%ebp)
8010218e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102191:	01 45 0c             	add    %eax,0xc(%ebp)
80102194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102197:	3b 45 14             	cmp    0x14(%ebp),%eax
8010219a:	0f 82 5d ff ff ff    	jb     801020fd <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
801021a0:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801021a4:	74 22                	je     801021c8 <writei+0x181>
801021a6:	8b 45 08             	mov    0x8(%ebp),%eax
801021a9:	8b 40 18             	mov    0x18(%eax),%eax
801021ac:	3b 45 10             	cmp    0x10(%ebp),%eax
801021af:	73 17                	jae    801021c8 <writei+0x181>
    ip->size = off;
801021b1:	8b 45 08             	mov    0x8(%ebp),%eax
801021b4:	8b 55 10             	mov    0x10(%ebp),%edx
801021b7:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801021ba:	83 ec 0c             	sub    $0xc,%esp
801021bd:	ff 75 08             	push   0x8(%ebp)
801021c0:	e8 ea f5 ff ff       	call   801017af <iupdate>
801021c5:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021c8:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021cb:	c9                   	leave
801021cc:	c3                   	ret

801021cd <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021cd:	55                   	push   %ebp
801021ce:	89 e5                	mov    %esp,%ebp
801021d0:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021d3:	83 ec 04             	sub    $0x4,%esp
801021d6:	6a 0e                	push   $0xe
801021d8:	ff 75 0c             	push   0xc(%ebp)
801021db:	ff 75 08             	push   0x8(%ebp)
801021de:	e8 1b 32 00 00       	call   801053fe <strncmp>
801021e3:	83 c4 10             	add    $0x10,%esp
}
801021e6:	c9                   	leave
801021e7:	c3                   	ret

801021e8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021e8:	55                   	push   %ebp
801021e9:	89 e5                	mov    %esp,%ebp
801021eb:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021ee:	8b 45 08             	mov    0x8(%ebp),%eax
801021f1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021f5:	66 83 f8 01          	cmp    $0x1,%ax
801021f9:	74 0d                	je     80102208 <dirlookup+0x20>
    panic("dirlookup not DIR");
801021fb:	83 ec 0c             	sub    $0xc,%esp
801021fe:	68 ef 86 10 80       	push   $0x801086ef
80102203:	e8 71 e3 ff ff       	call   80100579 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102208:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010220f:	eb 7b                	jmp    8010228c <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102211:	6a 10                	push   $0x10
80102213:	ff 75 f4             	push   -0xc(%ebp)
80102216:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102219:	50                   	push   %eax
8010221a:	ff 75 08             	push   0x8(%ebp)
8010221d:	e8 d0 fc ff ff       	call   80101ef2 <readi>
80102222:	83 c4 10             	add    $0x10,%esp
80102225:	83 f8 10             	cmp    $0x10,%eax
80102228:	74 0d                	je     80102237 <dirlookup+0x4f>
      panic("dirlink read");
8010222a:	83 ec 0c             	sub    $0xc,%esp
8010222d:	68 01 87 10 80       	push   $0x80108701
80102232:	e8 42 e3 ff ff       	call   80100579 <panic>
    if(de.inum == 0)
80102237:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010223b:	66 85 c0             	test   %ax,%ax
8010223e:	74 47                	je     80102287 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
80102240:	83 ec 08             	sub    $0x8,%esp
80102243:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102246:	83 c0 02             	add    $0x2,%eax
80102249:	50                   	push   %eax
8010224a:	ff 75 0c             	push   0xc(%ebp)
8010224d:	e8 7b ff ff ff       	call   801021cd <namecmp>
80102252:	83 c4 10             	add    $0x10,%esp
80102255:	85 c0                	test   %eax,%eax
80102257:	75 2f                	jne    80102288 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102259:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010225d:	74 08                	je     80102267 <dirlookup+0x7f>
        *poff = off;
8010225f:	8b 45 10             	mov    0x10(%ebp),%eax
80102262:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102265:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102267:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010226b:	0f b7 c0             	movzwl %ax,%eax
8010226e:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102271:	8b 45 08             	mov    0x8(%ebp),%eax
80102274:	8b 00                	mov    (%eax),%eax
80102276:	83 ec 08             	sub    $0x8,%esp
80102279:	ff 75 f0             	push   -0x10(%ebp)
8010227c:	50                   	push   %eax
8010227d:	e8 ee f5 ff ff       	call   80101870 <iget>
80102282:	83 c4 10             	add    $0x10,%esp
80102285:	eb 19                	jmp    801022a0 <dirlookup+0xb8>
      continue;
80102287:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102288:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010228c:	8b 45 08             	mov    0x8(%ebp),%eax
8010228f:	8b 40 18             	mov    0x18(%eax),%eax
80102292:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102295:	0f 82 76 ff ff ff    	jb     80102211 <dirlookup+0x29>
    }
  }

  return 0;
8010229b:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022a0:	c9                   	leave
801022a1:	c3                   	ret

801022a2 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801022a2:	55                   	push   %ebp
801022a3:	89 e5                	mov    %esp,%ebp
801022a5:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801022a8:	83 ec 04             	sub    $0x4,%esp
801022ab:	6a 00                	push   $0x0
801022ad:	ff 75 0c             	push   0xc(%ebp)
801022b0:	ff 75 08             	push   0x8(%ebp)
801022b3:	e8 30 ff ff ff       	call   801021e8 <dirlookup>
801022b8:	83 c4 10             	add    $0x10,%esp
801022bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022be:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022c2:	74 18                	je     801022dc <dirlink+0x3a>
    iput(ip);
801022c4:	83 ec 0c             	sub    $0xc,%esp
801022c7:	ff 75 f0             	push   -0x10(%ebp)
801022ca:	e8 8a f8 ff ff       	call   80101b59 <iput>
801022cf:	83 c4 10             	add    $0x10,%esp
    return -1;
801022d2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022d7:	e9 9c 00 00 00       	jmp    80102378 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022e3:	eb 39                	jmp    8010231e <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022e8:	6a 10                	push   $0x10
801022ea:	50                   	push   %eax
801022eb:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022ee:	50                   	push   %eax
801022ef:	ff 75 08             	push   0x8(%ebp)
801022f2:	e8 fb fb ff ff       	call   80101ef2 <readi>
801022f7:	83 c4 10             	add    $0x10,%esp
801022fa:	83 f8 10             	cmp    $0x10,%eax
801022fd:	74 0d                	je     8010230c <dirlink+0x6a>
      panic("dirlink read");
801022ff:	83 ec 0c             	sub    $0xc,%esp
80102302:	68 01 87 10 80       	push   $0x80108701
80102307:	e8 6d e2 ff ff       	call   80100579 <panic>
    if(de.inum == 0)
8010230c:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102310:	66 85 c0             	test   %ax,%ax
80102313:	74 18                	je     8010232d <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102315:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102318:	83 c0 10             	add    $0x10,%eax
8010231b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010231e:	8b 45 08             	mov    0x8(%ebp),%eax
80102321:	8b 40 18             	mov    0x18(%eax),%eax
80102324:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102327:	39 c2                	cmp    %eax,%edx
80102329:	72 ba                	jb     801022e5 <dirlink+0x43>
8010232b:	eb 01                	jmp    8010232e <dirlink+0x8c>
      break;
8010232d:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010232e:	83 ec 04             	sub    $0x4,%esp
80102331:	6a 0e                	push   $0xe
80102333:	ff 75 0c             	push   0xc(%ebp)
80102336:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102339:	83 c0 02             	add    $0x2,%eax
8010233c:	50                   	push   %eax
8010233d:	e8 12 31 00 00       	call   80105454 <strncpy>
80102342:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102345:	8b 45 10             	mov    0x10(%ebp),%eax
80102348:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010234c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010234f:	6a 10                	push   $0x10
80102351:	50                   	push   %eax
80102352:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102355:	50                   	push   %eax
80102356:	ff 75 08             	push   0x8(%ebp)
80102359:	e8 e9 fc ff ff       	call   80102047 <writei>
8010235e:	83 c4 10             	add    $0x10,%esp
80102361:	83 f8 10             	cmp    $0x10,%eax
80102364:	74 0d                	je     80102373 <dirlink+0xd1>
    panic("dirlink");
80102366:	83 ec 0c             	sub    $0xc,%esp
80102369:	68 0e 87 10 80       	push   $0x8010870e
8010236e:	e8 06 e2 ff ff       	call   80100579 <panic>
  
  return 0;
80102373:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102378:	c9                   	leave
80102379:	c3                   	ret

8010237a <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010237a:	55                   	push   %ebp
8010237b:	89 e5                	mov    %esp,%ebp
8010237d:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102380:	eb 04                	jmp    80102386 <skipelem+0xc>
    path++;
80102382:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102386:	8b 45 08             	mov    0x8(%ebp),%eax
80102389:	0f b6 00             	movzbl (%eax),%eax
8010238c:	3c 2f                	cmp    $0x2f,%al
8010238e:	74 f2                	je     80102382 <skipelem+0x8>
  if(*path == 0)
80102390:	8b 45 08             	mov    0x8(%ebp),%eax
80102393:	0f b6 00             	movzbl (%eax),%eax
80102396:	84 c0                	test   %al,%al
80102398:	75 07                	jne    801023a1 <skipelem+0x27>
    return 0;
8010239a:	b8 00 00 00 00       	mov    $0x0,%eax
8010239f:	eb 77                	jmp    80102418 <skipelem+0x9e>
  s = path;
801023a1:	8b 45 08             	mov    0x8(%ebp),%eax
801023a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801023a7:	eb 04                	jmp    801023ad <skipelem+0x33>
    path++;
801023a9:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
801023ad:	8b 45 08             	mov    0x8(%ebp),%eax
801023b0:	0f b6 00             	movzbl (%eax),%eax
801023b3:	3c 2f                	cmp    $0x2f,%al
801023b5:	74 0a                	je     801023c1 <skipelem+0x47>
801023b7:	8b 45 08             	mov    0x8(%ebp),%eax
801023ba:	0f b6 00             	movzbl (%eax),%eax
801023bd:	84 c0                	test   %al,%al
801023bf:	75 e8                	jne    801023a9 <skipelem+0x2f>
  len = path - s;
801023c1:	8b 45 08             	mov    0x8(%ebp),%eax
801023c4:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023ca:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023ce:	7e 15                	jle    801023e5 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023d0:	83 ec 04             	sub    $0x4,%esp
801023d3:	6a 0e                	push   $0xe
801023d5:	ff 75 f4             	push   -0xc(%ebp)
801023d8:	ff 75 0c             	push   0xc(%ebp)
801023db:	e8 88 2f 00 00       	call   80105368 <memmove>
801023e0:	83 c4 10             	add    $0x10,%esp
801023e3:	eb 26                	jmp    8010240b <skipelem+0x91>
  else {
    memmove(name, s, len);
801023e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023e8:	83 ec 04             	sub    $0x4,%esp
801023eb:	50                   	push   %eax
801023ec:	ff 75 f4             	push   -0xc(%ebp)
801023ef:	ff 75 0c             	push   0xc(%ebp)
801023f2:	e8 71 2f 00 00       	call   80105368 <memmove>
801023f7:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80102400:	01 d0                	add    %edx,%eax
80102402:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102405:	eb 04                	jmp    8010240b <skipelem+0x91>
    path++;
80102407:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
8010240b:	8b 45 08             	mov    0x8(%ebp),%eax
8010240e:	0f b6 00             	movzbl (%eax),%eax
80102411:	3c 2f                	cmp    $0x2f,%al
80102413:	74 f2                	je     80102407 <skipelem+0x8d>
  return path;
80102415:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102418:	c9                   	leave
80102419:	c3                   	ret

8010241a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010241a:	55                   	push   %ebp
8010241b:	89 e5                	mov    %esp,%ebp
8010241d:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
80102420:	8b 45 08             	mov    0x8(%ebp),%eax
80102423:	0f b6 00             	movzbl (%eax),%eax
80102426:	3c 2f                	cmp    $0x2f,%al
80102428:	75 17                	jne    80102441 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
8010242a:	83 ec 08             	sub    $0x8,%esp
8010242d:	6a 01                	push   $0x1
8010242f:	6a 01                	push   $0x1
80102431:	e8 3a f4 ff ff       	call   80101870 <iget>
80102436:	83 c4 10             	add    $0x10,%esp
80102439:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010243c:	e9 bb 00 00 00       	jmp    801024fc <namex+0xe2>
  else
    ip = idup(proc->cwd);
80102441:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102447:	8b 40 68             	mov    0x68(%eax),%eax
8010244a:	83 ec 0c             	sub    $0xc,%esp
8010244d:	50                   	push   %eax
8010244e:	e8 fc f4 ff ff       	call   8010194f <idup>
80102453:	83 c4 10             	add    $0x10,%esp
80102456:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102459:	e9 9e 00 00 00       	jmp    801024fc <namex+0xe2>
    ilock(ip);
8010245e:	83 ec 0c             	sub    $0xc,%esp
80102461:	ff 75 f4             	push   -0xc(%ebp)
80102464:	e8 20 f5 ff ff       	call   80101989 <ilock>
80102469:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010246c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010246f:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102473:	66 83 f8 01          	cmp    $0x1,%ax
80102477:	74 18                	je     80102491 <namex+0x77>
      iunlockput(ip);
80102479:	83 ec 0c             	sub    $0xc,%esp
8010247c:	ff 75 f4             	push   -0xc(%ebp)
8010247f:	e8 c5 f7 ff ff       	call   80101c49 <iunlockput>
80102484:	83 c4 10             	add    $0x10,%esp
      return 0;
80102487:	b8 00 00 00 00       	mov    $0x0,%eax
8010248c:	e9 a7 00 00 00       	jmp    80102538 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
80102491:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102495:	74 20                	je     801024b7 <namex+0x9d>
80102497:	8b 45 08             	mov    0x8(%ebp),%eax
8010249a:	0f b6 00             	movzbl (%eax),%eax
8010249d:	84 c0                	test   %al,%al
8010249f:	75 16                	jne    801024b7 <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
801024a1:	83 ec 0c             	sub    $0xc,%esp
801024a4:	ff 75 f4             	push   -0xc(%ebp)
801024a7:	e8 3b f6 ff ff       	call   80101ae7 <iunlock>
801024ac:	83 c4 10             	add    $0x10,%esp
      return ip;
801024af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024b2:	e9 81 00 00 00       	jmp    80102538 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024b7:	83 ec 04             	sub    $0x4,%esp
801024ba:	6a 00                	push   $0x0
801024bc:	ff 75 10             	push   0x10(%ebp)
801024bf:	ff 75 f4             	push   -0xc(%ebp)
801024c2:	e8 21 fd ff ff       	call   801021e8 <dirlookup>
801024c7:	83 c4 10             	add    $0x10,%esp
801024ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024d1:	75 15                	jne    801024e8 <namex+0xce>
      iunlockput(ip);
801024d3:	83 ec 0c             	sub    $0xc,%esp
801024d6:	ff 75 f4             	push   -0xc(%ebp)
801024d9:	e8 6b f7 ff ff       	call   80101c49 <iunlockput>
801024de:	83 c4 10             	add    $0x10,%esp
      return 0;
801024e1:	b8 00 00 00 00       	mov    $0x0,%eax
801024e6:	eb 50                	jmp    80102538 <namex+0x11e>
    }
    iunlockput(ip);
801024e8:	83 ec 0c             	sub    $0xc,%esp
801024eb:	ff 75 f4             	push   -0xc(%ebp)
801024ee:	e8 56 f7 ff ff       	call   80101c49 <iunlockput>
801024f3:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024f9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024fc:	83 ec 08             	sub    $0x8,%esp
801024ff:	ff 75 10             	push   0x10(%ebp)
80102502:	ff 75 08             	push   0x8(%ebp)
80102505:	e8 70 fe ff ff       	call   8010237a <skipelem>
8010250a:	83 c4 10             	add    $0x10,%esp
8010250d:	89 45 08             	mov    %eax,0x8(%ebp)
80102510:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102514:	0f 85 44 ff ff ff    	jne    8010245e <namex+0x44>
  }
  if(nameiparent){
8010251a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010251e:	74 15                	je     80102535 <namex+0x11b>
    iput(ip);
80102520:	83 ec 0c             	sub    $0xc,%esp
80102523:	ff 75 f4             	push   -0xc(%ebp)
80102526:	e8 2e f6 ff ff       	call   80101b59 <iput>
8010252b:	83 c4 10             	add    $0x10,%esp
    return 0;
8010252e:	b8 00 00 00 00       	mov    $0x0,%eax
80102533:	eb 03                	jmp    80102538 <namex+0x11e>
  }
  return ip;
80102535:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102538:	c9                   	leave
80102539:	c3                   	ret

8010253a <namei>:

struct inode*
namei(char *path)
{
8010253a:	55                   	push   %ebp
8010253b:	89 e5                	mov    %esp,%ebp
8010253d:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102540:	83 ec 04             	sub    $0x4,%esp
80102543:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102546:	50                   	push   %eax
80102547:	6a 00                	push   $0x0
80102549:	ff 75 08             	push   0x8(%ebp)
8010254c:	e8 c9 fe ff ff       	call   8010241a <namex>
80102551:	83 c4 10             	add    $0x10,%esp
}
80102554:	c9                   	leave
80102555:	c3                   	ret

80102556 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102556:	55                   	push   %ebp
80102557:	89 e5                	mov    %esp,%ebp
80102559:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010255c:	83 ec 04             	sub    $0x4,%esp
8010255f:	ff 75 0c             	push   0xc(%ebp)
80102562:	6a 01                	push   $0x1
80102564:	ff 75 08             	push   0x8(%ebp)
80102567:	e8 ae fe ff ff       	call   8010241a <namex>
8010256c:	83 c4 10             	add    $0x10,%esp
}
8010256f:	c9                   	leave
80102570:	c3                   	ret

80102571 <inb>:
{
80102571:	55                   	push   %ebp
80102572:	89 e5                	mov    %esp,%ebp
80102574:	83 ec 14             	sub    $0x14,%esp
80102577:	8b 45 08             	mov    0x8(%ebp),%eax
8010257a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010257e:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102582:	89 c2                	mov    %eax,%edx
80102584:	ec                   	in     (%dx),%al
80102585:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102588:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010258c:	c9                   	leave
8010258d:	c3                   	ret

8010258e <insl>:
{
8010258e:	55                   	push   %ebp
8010258f:	89 e5                	mov    %esp,%ebp
80102591:	57                   	push   %edi
80102592:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102593:	8b 55 08             	mov    0x8(%ebp),%edx
80102596:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102599:	8b 45 10             	mov    0x10(%ebp),%eax
8010259c:	89 cb                	mov    %ecx,%ebx
8010259e:	89 df                	mov    %ebx,%edi
801025a0:	89 c1                	mov    %eax,%ecx
801025a2:	fc                   	cld
801025a3:	f3 6d                	rep insl (%dx),%es:(%edi)
801025a5:	89 c8                	mov    %ecx,%eax
801025a7:	89 fb                	mov    %edi,%ebx
801025a9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025ac:	89 45 10             	mov    %eax,0x10(%ebp)
}
801025af:	90                   	nop
801025b0:	5b                   	pop    %ebx
801025b1:	5f                   	pop    %edi
801025b2:	5d                   	pop    %ebp
801025b3:	c3                   	ret

801025b4 <outb>:
{
801025b4:	55                   	push   %ebp
801025b5:	89 e5                	mov    %esp,%ebp
801025b7:	83 ec 08             	sub    $0x8,%esp
801025ba:	8b 55 08             	mov    0x8(%ebp),%edx
801025bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801025c0:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801025c4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025c7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025cb:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025cf:	ee                   	out    %al,(%dx)
}
801025d0:	90                   	nop
801025d1:	c9                   	leave
801025d2:	c3                   	ret

801025d3 <outsl>:
{
801025d3:	55                   	push   %ebp
801025d4:	89 e5                	mov    %esp,%ebp
801025d6:	56                   	push   %esi
801025d7:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025d8:	8b 55 08             	mov    0x8(%ebp),%edx
801025db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025de:	8b 45 10             	mov    0x10(%ebp),%eax
801025e1:	89 cb                	mov    %ecx,%ebx
801025e3:	89 de                	mov    %ebx,%esi
801025e5:	89 c1                	mov    %eax,%ecx
801025e7:	fc                   	cld
801025e8:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025ea:	89 c8                	mov    %ecx,%eax
801025ec:	89 f3                	mov    %esi,%ebx
801025ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025f1:	89 45 10             	mov    %eax,0x10(%ebp)
}
801025f4:	90                   	nop
801025f5:	5b                   	pop    %ebx
801025f6:	5e                   	pop    %esi
801025f7:	5d                   	pop    %ebp
801025f8:	c3                   	ret

801025f9 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025f9:	55                   	push   %ebp
801025fa:	89 e5                	mov    %esp,%ebp
801025fc:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801025ff:	90                   	nop
80102600:	68 f7 01 00 00       	push   $0x1f7
80102605:	e8 67 ff ff ff       	call   80102571 <inb>
8010260a:	83 c4 04             	add    $0x4,%esp
8010260d:	0f b6 c0             	movzbl %al,%eax
80102610:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102613:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102616:	25 c0 00 00 00       	and    $0xc0,%eax
8010261b:	83 f8 40             	cmp    $0x40,%eax
8010261e:	75 e0                	jne    80102600 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102620:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102624:	74 11                	je     80102637 <idewait+0x3e>
80102626:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102629:	83 e0 21             	and    $0x21,%eax
8010262c:	85 c0                	test   %eax,%eax
8010262e:	74 07                	je     80102637 <idewait+0x3e>
    return -1;
80102630:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102635:	eb 05                	jmp    8010263c <idewait+0x43>
  return 0;
80102637:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010263c:	c9                   	leave
8010263d:	c3                   	ret

8010263e <ideinit>:

void
ideinit(void)
{
8010263e:	55                   	push   %ebp
8010263f:	89 e5                	mov    %esp,%ebp
80102641:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102644:	83 ec 08             	sub    $0x8,%esp
80102647:	68 16 87 10 80       	push   $0x80108716
8010264c:	68 a0 11 11 80       	push   $0x801111a0
80102651:	e8 cd 29 00 00       	call   80105023 <initlock>
80102656:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102659:	83 ec 0c             	sub    $0xc,%esp
8010265c:	6a 0e                	push   $0xe
8010265e:	e8 eb 18 00 00       	call   80103f4e <picenable>
80102663:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102666:	a1 04 19 11 80       	mov    0x80111904,%eax
8010266b:	83 e8 01             	sub    $0x1,%eax
8010266e:	83 ec 08             	sub    $0x8,%esp
80102671:	50                   	push   %eax
80102672:	6a 0e                	push   $0xe
80102674:	e8 73 04 00 00       	call   80102aec <ioapicenable>
80102679:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010267c:	83 ec 0c             	sub    $0xc,%esp
8010267f:	6a 00                	push   $0x0
80102681:	e8 73 ff ff ff       	call   801025f9 <idewait>
80102686:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102689:	83 ec 08             	sub    $0x8,%esp
8010268c:	68 f0 00 00 00       	push   $0xf0
80102691:	68 f6 01 00 00       	push   $0x1f6
80102696:	e8 19 ff ff ff       	call   801025b4 <outb>
8010269b:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
8010269e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801026a5:	eb 24                	jmp    801026cb <ideinit+0x8d>
    if(inb(0x1f7) != 0){
801026a7:	83 ec 0c             	sub    $0xc,%esp
801026aa:	68 f7 01 00 00       	push   $0x1f7
801026af:	e8 bd fe ff ff       	call   80102571 <inb>
801026b4:	83 c4 10             	add    $0x10,%esp
801026b7:	84 c0                	test   %al,%al
801026b9:	74 0c                	je     801026c7 <ideinit+0x89>
      havedisk1 = 1;
801026bb:	c7 05 d8 11 11 80 01 	movl   $0x1,0x801111d8
801026c2:	00 00 00 
      break;
801026c5:	eb 0d                	jmp    801026d4 <ideinit+0x96>
  for(i=0; i<1000; i++){
801026c7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026cb:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026d2:	7e d3                	jle    801026a7 <ideinit+0x69>
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026d4:	83 ec 08             	sub    $0x8,%esp
801026d7:	68 e0 00 00 00       	push   $0xe0
801026dc:	68 f6 01 00 00       	push   $0x1f6
801026e1:	e8 ce fe ff ff       	call   801025b4 <outb>
801026e6:	83 c4 10             	add    $0x10,%esp
}
801026e9:	90                   	nop
801026ea:	c9                   	leave
801026eb:	c3                   	ret

801026ec <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026ec:	55                   	push   %ebp
801026ed:	89 e5                	mov    %esp,%ebp
801026ef:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801026f2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026f6:	75 0d                	jne    80102705 <idestart+0x19>
    panic("idestart");
801026f8:	83 ec 0c             	sub    $0xc,%esp
801026fb:	68 1a 87 10 80       	push   $0x8010871a
80102700:	e8 74 de ff ff       	call   80100579 <panic>
  if(b->blockno >= FSSIZE)
80102705:	8b 45 08             	mov    0x8(%ebp),%eax
80102708:	8b 40 08             	mov    0x8(%eax),%eax
8010270b:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102710:	76 0d                	jbe    8010271f <idestart+0x33>
    panic("incorrect blockno");
80102712:	83 ec 0c             	sub    $0xc,%esp
80102715:	68 23 87 10 80       	push   $0x80108723
8010271a:	e8 5a de ff ff       	call   80100579 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
8010271f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102726:	8b 45 08             	mov    0x8(%ebp),%eax
80102729:	8b 50 08             	mov    0x8(%eax),%edx
8010272c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010272f:	0f af c2             	imul   %edx,%eax
80102732:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102735:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102739:	7e 0d                	jle    80102748 <idestart+0x5c>
8010273b:	83 ec 0c             	sub    $0xc,%esp
8010273e:	68 1a 87 10 80       	push   $0x8010871a
80102743:	e8 31 de ff ff       	call   80100579 <panic>
  
  idewait(0);
80102748:	83 ec 0c             	sub    $0xc,%esp
8010274b:	6a 00                	push   $0x0
8010274d:	e8 a7 fe ff ff       	call   801025f9 <idewait>
80102752:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102755:	83 ec 08             	sub    $0x8,%esp
80102758:	6a 00                	push   $0x0
8010275a:	68 f6 03 00 00       	push   $0x3f6
8010275f:	e8 50 fe ff ff       	call   801025b4 <outb>
80102764:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010276a:	0f b6 c0             	movzbl %al,%eax
8010276d:	83 ec 08             	sub    $0x8,%esp
80102770:	50                   	push   %eax
80102771:	68 f2 01 00 00       	push   $0x1f2
80102776:	e8 39 fe ff ff       	call   801025b4 <outb>
8010277b:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
8010277e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102781:	0f b6 c0             	movzbl %al,%eax
80102784:	83 ec 08             	sub    $0x8,%esp
80102787:	50                   	push   %eax
80102788:	68 f3 01 00 00       	push   $0x1f3
8010278d:	e8 22 fe ff ff       	call   801025b4 <outb>
80102792:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102795:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102798:	c1 f8 08             	sar    $0x8,%eax
8010279b:	0f b6 c0             	movzbl %al,%eax
8010279e:	83 ec 08             	sub    $0x8,%esp
801027a1:	50                   	push   %eax
801027a2:	68 f4 01 00 00       	push   $0x1f4
801027a7:	e8 08 fe ff ff       	call   801025b4 <outb>
801027ac:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
801027af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027b2:	c1 f8 10             	sar    $0x10,%eax
801027b5:	0f b6 c0             	movzbl %al,%eax
801027b8:	83 ec 08             	sub    $0x8,%esp
801027bb:	50                   	push   %eax
801027bc:	68 f5 01 00 00       	push   $0x1f5
801027c1:	e8 ee fd ff ff       	call   801025b4 <outb>
801027c6:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801027c9:	8b 45 08             	mov    0x8(%ebp),%eax
801027cc:	8b 40 04             	mov    0x4(%eax),%eax
801027cf:	c1 e0 04             	shl    $0x4,%eax
801027d2:	83 e0 10             	and    $0x10,%eax
801027d5:	89 c2                	mov    %eax,%edx
801027d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027da:	c1 f8 18             	sar    $0x18,%eax
801027dd:	83 e0 0f             	and    $0xf,%eax
801027e0:	09 d0                	or     %edx,%eax
801027e2:	83 c8 e0             	or     $0xffffffe0,%eax
801027e5:	0f b6 c0             	movzbl %al,%eax
801027e8:	83 ec 08             	sub    $0x8,%esp
801027eb:	50                   	push   %eax
801027ec:	68 f6 01 00 00       	push   $0x1f6
801027f1:	e8 be fd ff ff       	call   801025b4 <outb>
801027f6:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801027f9:	8b 45 08             	mov    0x8(%ebp),%eax
801027fc:	8b 00                	mov    (%eax),%eax
801027fe:	83 e0 04             	and    $0x4,%eax
80102801:	85 c0                	test   %eax,%eax
80102803:	74 30                	je     80102835 <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
80102805:	83 ec 08             	sub    $0x8,%esp
80102808:	6a 30                	push   $0x30
8010280a:	68 f7 01 00 00       	push   $0x1f7
8010280f:	e8 a0 fd ff ff       	call   801025b4 <outb>
80102814:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102817:	8b 45 08             	mov    0x8(%ebp),%eax
8010281a:	83 c0 18             	add    $0x18,%eax
8010281d:	83 ec 04             	sub    $0x4,%esp
80102820:	68 80 00 00 00       	push   $0x80
80102825:	50                   	push   %eax
80102826:	68 f0 01 00 00       	push   $0x1f0
8010282b:	e8 a3 fd ff ff       	call   801025d3 <outsl>
80102830:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102833:	eb 12                	jmp    80102847 <idestart+0x15b>
    outb(0x1f7, IDE_CMD_READ);
80102835:	83 ec 08             	sub    $0x8,%esp
80102838:	6a 20                	push   $0x20
8010283a:	68 f7 01 00 00       	push   $0x1f7
8010283f:	e8 70 fd ff ff       	call   801025b4 <outb>
80102844:	83 c4 10             	add    $0x10,%esp
}
80102847:	90                   	nop
80102848:	c9                   	leave
80102849:	c3                   	ret

8010284a <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010284a:	55                   	push   %ebp
8010284b:	89 e5                	mov    %esp,%ebp
8010284d:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102850:	83 ec 0c             	sub    $0xc,%esp
80102853:	68 a0 11 11 80       	push   $0x801111a0
80102858:	e8 e8 27 00 00       	call   80105045 <acquire>
8010285d:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102860:	a1 d4 11 11 80       	mov    0x801111d4,%eax
80102865:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102868:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010286c:	75 15                	jne    80102883 <ideintr+0x39>
    release(&idelock);
8010286e:	83 ec 0c             	sub    $0xc,%esp
80102871:	68 a0 11 11 80       	push   $0x801111a0
80102876:	e8 31 28 00 00       	call   801050ac <release>
8010287b:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
8010287e:	e9 9a 00 00 00       	jmp    8010291d <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102883:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102886:	8b 40 14             	mov    0x14(%eax),%eax
80102889:	a3 d4 11 11 80       	mov    %eax,0x801111d4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010288e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102891:	8b 00                	mov    (%eax),%eax
80102893:	83 e0 04             	and    $0x4,%eax
80102896:	85 c0                	test   %eax,%eax
80102898:	75 2d                	jne    801028c7 <ideintr+0x7d>
8010289a:	83 ec 0c             	sub    $0xc,%esp
8010289d:	6a 01                	push   $0x1
8010289f:	e8 55 fd ff ff       	call   801025f9 <idewait>
801028a4:	83 c4 10             	add    $0x10,%esp
801028a7:	85 c0                	test   %eax,%eax
801028a9:	78 1c                	js     801028c7 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
801028ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ae:	83 c0 18             	add    $0x18,%eax
801028b1:	83 ec 04             	sub    $0x4,%esp
801028b4:	68 80 00 00 00       	push   $0x80
801028b9:	50                   	push   %eax
801028ba:	68 f0 01 00 00       	push   $0x1f0
801028bf:	e8 ca fc ff ff       	call   8010258e <insl>
801028c4:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801028c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ca:	8b 00                	mov    (%eax),%eax
801028cc:	83 c8 02             	or     $0x2,%eax
801028cf:	89 c2                	mov    %eax,%edx
801028d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d4:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801028d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d9:	8b 00                	mov    (%eax),%eax
801028db:	83 e0 fb             	and    $0xfffffffb,%eax
801028de:	89 c2                	mov    %eax,%edx
801028e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e3:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801028e5:	83 ec 0c             	sub    $0xc,%esp
801028e8:	ff 75 f4             	push   -0xc(%ebp)
801028eb:	e8 46 25 00 00       	call   80104e36 <wakeup>
801028f0:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
801028f3:	a1 d4 11 11 80       	mov    0x801111d4,%eax
801028f8:	85 c0                	test   %eax,%eax
801028fa:	74 11                	je     8010290d <ideintr+0xc3>
    idestart(idequeue);
801028fc:	a1 d4 11 11 80       	mov    0x801111d4,%eax
80102901:	83 ec 0c             	sub    $0xc,%esp
80102904:	50                   	push   %eax
80102905:	e8 e2 fd ff ff       	call   801026ec <idestart>
8010290a:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
8010290d:	83 ec 0c             	sub    $0xc,%esp
80102910:	68 a0 11 11 80       	push   $0x801111a0
80102915:	e8 92 27 00 00       	call   801050ac <release>
8010291a:	83 c4 10             	add    $0x10,%esp
}
8010291d:	c9                   	leave
8010291e:	c3                   	ret

8010291f <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010291f:	55                   	push   %ebp
80102920:	89 e5                	mov    %esp,%ebp
80102922:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102925:	8b 45 08             	mov    0x8(%ebp),%eax
80102928:	8b 00                	mov    (%eax),%eax
8010292a:	83 e0 01             	and    $0x1,%eax
8010292d:	85 c0                	test   %eax,%eax
8010292f:	75 0d                	jne    8010293e <iderw+0x1f>
    panic("iderw: buf not busy");
80102931:	83 ec 0c             	sub    $0xc,%esp
80102934:	68 35 87 10 80       	push   $0x80108735
80102939:	e8 3b dc ff ff       	call   80100579 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010293e:	8b 45 08             	mov    0x8(%ebp),%eax
80102941:	8b 00                	mov    (%eax),%eax
80102943:	83 e0 06             	and    $0x6,%eax
80102946:	83 f8 02             	cmp    $0x2,%eax
80102949:	75 0d                	jne    80102958 <iderw+0x39>
    panic("iderw: nothing to do");
8010294b:	83 ec 0c             	sub    $0xc,%esp
8010294e:	68 49 87 10 80       	push   $0x80108749
80102953:	e8 21 dc ff ff       	call   80100579 <panic>
  if(b->dev != 0 && !havedisk1)
80102958:	8b 45 08             	mov    0x8(%ebp),%eax
8010295b:	8b 40 04             	mov    0x4(%eax),%eax
8010295e:	85 c0                	test   %eax,%eax
80102960:	74 16                	je     80102978 <iderw+0x59>
80102962:	a1 d8 11 11 80       	mov    0x801111d8,%eax
80102967:	85 c0                	test   %eax,%eax
80102969:	75 0d                	jne    80102978 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
8010296b:	83 ec 0c             	sub    $0xc,%esp
8010296e:	68 5e 87 10 80       	push   $0x8010875e
80102973:	e8 01 dc ff ff       	call   80100579 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102978:	83 ec 0c             	sub    $0xc,%esp
8010297b:	68 a0 11 11 80       	push   $0x801111a0
80102980:	e8 c0 26 00 00       	call   80105045 <acquire>
80102985:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102988:	8b 45 08             	mov    0x8(%ebp),%eax
8010298b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102992:	c7 45 f4 d4 11 11 80 	movl   $0x801111d4,-0xc(%ebp)
80102999:	eb 0b                	jmp    801029a6 <iderw+0x87>
8010299b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010299e:	8b 00                	mov    (%eax),%eax
801029a0:	83 c0 14             	add    $0x14,%eax
801029a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029a9:	8b 00                	mov    (%eax),%eax
801029ab:	85 c0                	test   %eax,%eax
801029ad:	75 ec                	jne    8010299b <iderw+0x7c>
    ;
  *pp = b;
801029af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029b2:	8b 55 08             	mov    0x8(%ebp),%edx
801029b5:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
801029b7:	a1 d4 11 11 80       	mov    0x801111d4,%eax
801029bc:	39 45 08             	cmp    %eax,0x8(%ebp)
801029bf:	75 23                	jne    801029e4 <iderw+0xc5>
    idestart(b);
801029c1:	83 ec 0c             	sub    $0xc,%esp
801029c4:	ff 75 08             	push   0x8(%ebp)
801029c7:	e8 20 fd ff ff       	call   801026ec <idestart>
801029cc:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029cf:	eb 13                	jmp    801029e4 <iderw+0xc5>
    sleep(b, &idelock);
801029d1:	83 ec 08             	sub    $0x8,%esp
801029d4:	68 a0 11 11 80       	push   $0x801111a0
801029d9:	ff 75 08             	push   0x8(%ebp)
801029dc:	e8 69 23 00 00       	call   80104d4a <sleep>
801029e1:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029e4:	8b 45 08             	mov    0x8(%ebp),%eax
801029e7:	8b 00                	mov    (%eax),%eax
801029e9:	83 e0 06             	and    $0x6,%eax
801029ec:	83 f8 02             	cmp    $0x2,%eax
801029ef:	75 e0                	jne    801029d1 <iderw+0xb2>
  }

  release(&idelock);
801029f1:	83 ec 0c             	sub    $0xc,%esp
801029f4:	68 a0 11 11 80       	push   $0x801111a0
801029f9:	e8 ae 26 00 00       	call   801050ac <release>
801029fe:	83 c4 10             	add    $0x10,%esp
}
80102a01:	90                   	nop
80102a02:	c9                   	leave
80102a03:	c3                   	ret

80102a04 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a04:	55                   	push   %ebp
80102a05:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a07:	a1 dc 11 11 80       	mov    0x801111dc,%eax
80102a0c:	8b 55 08             	mov    0x8(%ebp),%edx
80102a0f:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a11:	a1 dc 11 11 80       	mov    0x801111dc,%eax
80102a16:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a19:	5d                   	pop    %ebp
80102a1a:	c3                   	ret

80102a1b <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a1b:	55                   	push   %ebp
80102a1c:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a1e:	a1 dc 11 11 80       	mov    0x801111dc,%eax
80102a23:	8b 55 08             	mov    0x8(%ebp),%edx
80102a26:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a28:	a1 dc 11 11 80       	mov    0x801111dc,%eax
80102a2d:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a30:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a33:	90                   	nop
80102a34:	5d                   	pop    %ebp
80102a35:	c3                   	ret

80102a36 <ioapicinit>:

void
ioapicinit(void)
{
80102a36:	55                   	push   %ebp
80102a37:	89 e5                	mov    %esp,%ebp
80102a39:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102a3c:	a1 00 19 11 80       	mov    0x80111900,%eax
80102a41:	85 c0                	test   %eax,%eax
80102a43:	0f 84 a0 00 00 00    	je     80102ae9 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a49:	c7 05 dc 11 11 80 00 	movl   $0xfec00000,0x801111dc
80102a50:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a53:	6a 01                	push   $0x1
80102a55:	e8 aa ff ff ff       	call   80102a04 <ioapicread>
80102a5a:	83 c4 04             	add    $0x4,%esp
80102a5d:	c1 e8 10             	shr    $0x10,%eax
80102a60:	25 ff 00 00 00       	and    $0xff,%eax
80102a65:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a68:	6a 00                	push   $0x0
80102a6a:	e8 95 ff ff ff       	call   80102a04 <ioapicread>
80102a6f:	83 c4 04             	add    $0x4,%esp
80102a72:	c1 e8 18             	shr    $0x18,%eax
80102a75:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102a78:	0f b6 05 08 19 11 80 	movzbl 0x80111908,%eax
80102a7f:	0f b6 c0             	movzbl %al,%eax
80102a82:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102a85:	74 10                	je     80102a97 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102a87:	83 ec 0c             	sub    $0xc,%esp
80102a8a:	68 7c 87 10 80       	push   $0x8010877c
80102a8f:	e8 30 d9 ff ff       	call   801003c4 <cprintf>
80102a94:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a9e:	eb 3f                	jmp    80102adf <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aa3:	83 c0 20             	add    $0x20,%eax
80102aa6:	0d 00 00 01 00       	or     $0x10000,%eax
80102aab:	89 c2                	mov    %eax,%edx
80102aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab0:	83 c0 08             	add    $0x8,%eax
80102ab3:	01 c0                	add    %eax,%eax
80102ab5:	83 ec 08             	sub    $0x8,%esp
80102ab8:	52                   	push   %edx
80102ab9:	50                   	push   %eax
80102aba:	e8 5c ff ff ff       	call   80102a1b <ioapicwrite>
80102abf:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac5:	83 c0 08             	add    $0x8,%eax
80102ac8:	01 c0                	add    %eax,%eax
80102aca:	83 c0 01             	add    $0x1,%eax
80102acd:	83 ec 08             	sub    $0x8,%esp
80102ad0:	6a 00                	push   $0x0
80102ad2:	50                   	push   %eax
80102ad3:	e8 43 ff ff ff       	call   80102a1b <ioapicwrite>
80102ad8:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102adb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102ae5:	7e b9                	jle    80102aa0 <ioapicinit+0x6a>
80102ae7:	eb 01                	jmp    80102aea <ioapicinit+0xb4>
    return;
80102ae9:	90                   	nop
  }
}
80102aea:	c9                   	leave
80102aeb:	c3                   	ret

80102aec <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102aec:	55                   	push   %ebp
80102aed:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102aef:	a1 00 19 11 80       	mov    0x80111900,%eax
80102af4:	85 c0                	test   %eax,%eax
80102af6:	74 39                	je     80102b31 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102af8:	8b 45 08             	mov    0x8(%ebp),%eax
80102afb:	83 c0 20             	add    $0x20,%eax
80102afe:	89 c2                	mov    %eax,%edx
80102b00:	8b 45 08             	mov    0x8(%ebp),%eax
80102b03:	83 c0 08             	add    $0x8,%eax
80102b06:	01 c0                	add    %eax,%eax
80102b08:	52                   	push   %edx
80102b09:	50                   	push   %eax
80102b0a:	e8 0c ff ff ff       	call   80102a1b <ioapicwrite>
80102b0f:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b12:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b15:	c1 e0 18             	shl    $0x18,%eax
80102b18:	89 c2                	mov    %eax,%edx
80102b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b1d:	83 c0 08             	add    $0x8,%eax
80102b20:	01 c0                	add    %eax,%eax
80102b22:	83 c0 01             	add    $0x1,%eax
80102b25:	52                   	push   %edx
80102b26:	50                   	push   %eax
80102b27:	e8 ef fe ff ff       	call   80102a1b <ioapicwrite>
80102b2c:	83 c4 08             	add    $0x8,%esp
80102b2f:	eb 01                	jmp    80102b32 <ioapicenable+0x46>
    return;
80102b31:	90                   	nop
}
80102b32:	c9                   	leave
80102b33:	c3                   	ret

80102b34 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102b34:	55                   	push   %ebp
80102b35:	89 e5                	mov    %esp,%ebp
80102b37:	8b 45 08             	mov    0x8(%ebp),%eax
80102b3a:	05 00 00 00 80       	add    $0x80000000,%eax
80102b3f:	5d                   	pop    %ebp
80102b40:	c3                   	ret

80102b41 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b41:	55                   	push   %ebp
80102b42:	89 e5                	mov    %esp,%ebp
80102b44:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b47:	83 ec 08             	sub    $0x8,%esp
80102b4a:	68 ae 87 10 80       	push   $0x801087ae
80102b4f:	68 e0 11 11 80       	push   $0x801111e0
80102b54:	e8 ca 24 00 00       	call   80105023 <initlock>
80102b59:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b5c:	c7 05 14 12 11 80 00 	movl   $0x0,0x80111214
80102b63:	00 00 00 
  freerange(vstart, vend);
80102b66:	83 ec 08             	sub    $0x8,%esp
80102b69:	ff 75 0c             	push   0xc(%ebp)
80102b6c:	ff 75 08             	push   0x8(%ebp)
80102b6f:	e8 2a 00 00 00       	call   80102b9e <freerange>
80102b74:	83 c4 10             	add    $0x10,%esp
}
80102b77:	90                   	nop
80102b78:	c9                   	leave
80102b79:	c3                   	ret

80102b7a <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b7a:	55                   	push   %ebp
80102b7b:	89 e5                	mov    %esp,%ebp
80102b7d:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102b80:	83 ec 08             	sub    $0x8,%esp
80102b83:	ff 75 0c             	push   0xc(%ebp)
80102b86:	ff 75 08             	push   0x8(%ebp)
80102b89:	e8 10 00 00 00       	call   80102b9e <freerange>
80102b8e:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102b91:	c7 05 14 12 11 80 01 	movl   $0x1,0x80111214
80102b98:	00 00 00 
}
80102b9b:	90                   	nop
80102b9c:	c9                   	leave
80102b9d:	c3                   	ret

80102b9e <freerange>:

void
freerange(void *vstart, void *vend)
{
80102b9e:	55                   	push   %ebp
80102b9f:	89 e5                	mov    %esp,%ebp
80102ba1:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102ba4:	8b 45 08             	mov    0x8(%ebp),%eax
80102ba7:	05 ff 0f 00 00       	add    $0xfff,%eax
80102bac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102bb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bb4:	eb 15                	jmp    80102bcb <freerange+0x2d>
    kfree(p);
80102bb6:	83 ec 0c             	sub    $0xc,%esp
80102bb9:	ff 75 f4             	push   -0xc(%ebp)
80102bbc:	e8 1b 00 00 00       	call   80102bdc <kfree>
80102bc1:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bc4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bce:	05 00 10 00 00       	add    $0x1000,%eax
80102bd3:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102bd6:	73 de                	jae    80102bb6 <freerange+0x18>
}
80102bd8:	90                   	nop
80102bd9:	90                   	nop
80102bda:	c9                   	leave
80102bdb:	c3                   	ret

80102bdc <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102bdc:	55                   	push   %ebp
80102bdd:	89 e5                	mov    %esp,%ebp
80102bdf:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102be2:	8b 45 08             	mov    0x8(%ebp),%eax
80102be5:	25 ff 0f 00 00       	and    $0xfff,%eax
80102bea:	85 c0                	test   %eax,%eax
80102bec:	75 1b                	jne    80102c09 <kfree+0x2d>
80102bee:	81 7d 08 00 51 11 80 	cmpl   $0x80115100,0x8(%ebp)
80102bf5:	72 12                	jb     80102c09 <kfree+0x2d>
80102bf7:	ff 75 08             	push   0x8(%ebp)
80102bfa:	e8 35 ff ff ff       	call   80102b34 <v2p>
80102bff:	83 c4 04             	add    $0x4,%esp
80102c02:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c07:	76 0d                	jbe    80102c16 <kfree+0x3a>
    panic("kfree");
80102c09:	83 ec 0c             	sub    $0xc,%esp
80102c0c:	68 b3 87 10 80       	push   $0x801087b3
80102c11:	e8 63 d9 ff ff       	call   80100579 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c16:	83 ec 04             	sub    $0x4,%esp
80102c19:	68 00 10 00 00       	push   $0x1000
80102c1e:	6a 01                	push   $0x1
80102c20:	ff 75 08             	push   0x8(%ebp)
80102c23:	e8 81 26 00 00       	call   801052a9 <memset>
80102c28:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c2b:	a1 14 12 11 80       	mov    0x80111214,%eax
80102c30:	85 c0                	test   %eax,%eax
80102c32:	74 10                	je     80102c44 <kfree+0x68>
    acquire(&kmem.lock);
80102c34:	83 ec 0c             	sub    $0xc,%esp
80102c37:	68 e0 11 11 80       	push   $0x801111e0
80102c3c:	e8 04 24 00 00       	call   80105045 <acquire>
80102c41:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c44:	8b 45 08             	mov    0x8(%ebp),%eax
80102c47:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c4a:	8b 15 18 12 11 80    	mov    0x80111218,%edx
80102c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c53:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c58:	a3 18 12 11 80       	mov    %eax,0x80111218
  if(kmem.use_lock)
80102c5d:	a1 14 12 11 80       	mov    0x80111214,%eax
80102c62:	85 c0                	test   %eax,%eax
80102c64:	74 10                	je     80102c76 <kfree+0x9a>
    release(&kmem.lock);
80102c66:	83 ec 0c             	sub    $0xc,%esp
80102c69:	68 e0 11 11 80       	push   $0x801111e0
80102c6e:	e8 39 24 00 00       	call   801050ac <release>
80102c73:	83 c4 10             	add    $0x10,%esp
}
80102c76:	90                   	nop
80102c77:	c9                   	leave
80102c78:	c3                   	ret

80102c79 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c79:	55                   	push   %ebp
80102c7a:	89 e5                	mov    %esp,%ebp
80102c7c:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c7f:	a1 14 12 11 80       	mov    0x80111214,%eax
80102c84:	85 c0                	test   %eax,%eax
80102c86:	74 10                	je     80102c98 <kalloc+0x1f>
    acquire(&kmem.lock);
80102c88:	83 ec 0c             	sub    $0xc,%esp
80102c8b:	68 e0 11 11 80       	push   $0x801111e0
80102c90:	e8 b0 23 00 00       	call   80105045 <acquire>
80102c95:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102c98:	a1 18 12 11 80       	mov    0x80111218,%eax
80102c9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102ca0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102ca4:	74 0a                	je     80102cb0 <kalloc+0x37>
    kmem.freelist = r->next;
80102ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ca9:	8b 00                	mov    (%eax),%eax
80102cab:	a3 18 12 11 80       	mov    %eax,0x80111218
  if(kmem.use_lock)
80102cb0:	a1 14 12 11 80       	mov    0x80111214,%eax
80102cb5:	85 c0                	test   %eax,%eax
80102cb7:	74 10                	je     80102cc9 <kalloc+0x50>
    release(&kmem.lock);
80102cb9:	83 ec 0c             	sub    $0xc,%esp
80102cbc:	68 e0 11 11 80       	push   $0x801111e0
80102cc1:	e8 e6 23 00 00       	call   801050ac <release>
80102cc6:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102ccc:	c9                   	leave
80102ccd:	c3                   	ret

80102cce <inb>:
{
80102cce:	55                   	push   %ebp
80102ccf:	89 e5                	mov    %esp,%ebp
80102cd1:	83 ec 14             	sub    $0x14,%esp
80102cd4:	8b 45 08             	mov    0x8(%ebp),%eax
80102cd7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cdb:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cdf:	89 c2                	mov    %eax,%edx
80102ce1:	ec                   	in     (%dx),%al
80102ce2:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102ce5:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102ce9:	c9                   	leave
80102cea:	c3                   	ret

80102ceb <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102ceb:	55                   	push   %ebp
80102cec:	89 e5                	mov    %esp,%ebp
80102cee:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102cf1:	6a 64                	push   $0x64
80102cf3:	e8 d6 ff ff ff       	call   80102cce <inb>
80102cf8:	83 c4 04             	add    $0x4,%esp
80102cfb:	0f b6 c0             	movzbl %al,%eax
80102cfe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d04:	83 e0 01             	and    $0x1,%eax
80102d07:	85 c0                	test   %eax,%eax
80102d09:	75 0a                	jne    80102d15 <kbdgetc+0x2a>
    return -1;
80102d0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d10:	e9 23 01 00 00       	jmp    80102e38 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d15:	6a 60                	push   $0x60
80102d17:	e8 b2 ff ff ff       	call   80102cce <inb>
80102d1c:	83 c4 04             	add    $0x4,%esp
80102d1f:	0f b6 c0             	movzbl %al,%eax
80102d22:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d25:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d2c:	75 17                	jne    80102d45 <kbdgetc+0x5a>
    shift |= E0ESC;
80102d2e:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102d33:	83 c8 40             	or     $0x40,%eax
80102d36:	a3 1c 12 11 80       	mov    %eax,0x8011121c
    return 0;
80102d3b:	b8 00 00 00 00       	mov    $0x0,%eax
80102d40:	e9 f3 00 00 00       	jmp    80102e38 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d45:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d48:	25 80 00 00 00       	and    $0x80,%eax
80102d4d:	85 c0                	test   %eax,%eax
80102d4f:	74 45                	je     80102d96 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d51:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102d56:	83 e0 40             	and    $0x40,%eax
80102d59:	85 c0                	test   %eax,%eax
80102d5b:	75 08                	jne    80102d65 <kbdgetc+0x7a>
80102d5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d60:	83 e0 7f             	and    $0x7f,%eax
80102d63:	eb 03                	jmp    80102d68 <kbdgetc+0x7d>
80102d65:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d68:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d6e:	05 20 90 10 80       	add    $0x80109020,%eax
80102d73:	0f b6 00             	movzbl (%eax),%eax
80102d76:	83 c8 40             	or     $0x40,%eax
80102d79:	0f b6 c0             	movzbl %al,%eax
80102d7c:	f7 d0                	not    %eax
80102d7e:	89 c2                	mov    %eax,%edx
80102d80:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102d85:	21 d0                	and    %edx,%eax
80102d87:	a3 1c 12 11 80       	mov    %eax,0x8011121c
    return 0;
80102d8c:	b8 00 00 00 00       	mov    $0x0,%eax
80102d91:	e9 a2 00 00 00       	jmp    80102e38 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102d96:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102d9b:	83 e0 40             	and    $0x40,%eax
80102d9e:	85 c0                	test   %eax,%eax
80102da0:	74 14                	je     80102db6 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102da2:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102da9:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102dae:	83 e0 bf             	and    $0xffffffbf,%eax
80102db1:	a3 1c 12 11 80       	mov    %eax,0x8011121c
  }

  shift |= shiftcode[data];
80102db6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102db9:	05 20 90 10 80       	add    $0x80109020,%eax
80102dbe:	0f b6 00             	movzbl (%eax),%eax
80102dc1:	0f b6 d0             	movzbl %al,%edx
80102dc4:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102dc9:	09 d0                	or     %edx,%eax
80102dcb:	a3 1c 12 11 80       	mov    %eax,0x8011121c
  shift ^= togglecode[data];
80102dd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dd3:	05 20 91 10 80       	add    $0x80109120,%eax
80102dd8:	0f b6 00             	movzbl (%eax),%eax
80102ddb:	0f b6 d0             	movzbl %al,%edx
80102dde:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102de3:	31 d0                	xor    %edx,%eax
80102de5:	a3 1c 12 11 80       	mov    %eax,0x8011121c
  c = charcode[shift & (CTL | SHIFT)][data];
80102dea:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102def:	83 e0 03             	and    $0x3,%eax
80102df2:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102df9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dfc:	01 d0                	add    %edx,%eax
80102dfe:	0f b6 00             	movzbl (%eax),%eax
80102e01:	0f b6 c0             	movzbl %al,%eax
80102e04:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e07:	a1 1c 12 11 80       	mov    0x8011121c,%eax
80102e0c:	83 e0 08             	and    $0x8,%eax
80102e0f:	85 c0                	test   %eax,%eax
80102e11:	74 22                	je     80102e35 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e13:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e17:	76 0c                	jbe    80102e25 <kbdgetc+0x13a>
80102e19:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e1d:	77 06                	ja     80102e25 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e1f:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e23:	eb 10                	jmp    80102e35 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e25:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e29:	76 0a                	jbe    80102e35 <kbdgetc+0x14a>
80102e2b:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e2f:	77 04                	ja     80102e35 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e31:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e35:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e38:	c9                   	leave
80102e39:	c3                   	ret

80102e3a <kbdintr>:

void
kbdintr(void)
{
80102e3a:	55                   	push   %ebp
80102e3b:	89 e5                	mov    %esp,%ebp
80102e3d:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e40:	83 ec 0c             	sub    $0xc,%esp
80102e43:	68 eb 2c 10 80       	push   $0x80102ceb
80102e48:	e8 c9 d9 ff ff       	call   80100816 <consoleintr>
80102e4d:	83 c4 10             	add    $0x10,%esp
}
80102e50:	90                   	nop
80102e51:	c9                   	leave
80102e52:	c3                   	ret

80102e53 <inb>:
{
80102e53:	55                   	push   %ebp
80102e54:	89 e5                	mov    %esp,%ebp
80102e56:	83 ec 14             	sub    $0x14,%esp
80102e59:	8b 45 08             	mov    0x8(%ebp),%eax
80102e5c:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e60:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e64:	89 c2                	mov    %eax,%edx
80102e66:	ec                   	in     (%dx),%al
80102e67:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e6a:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e6e:	c9                   	leave
80102e6f:	c3                   	ret

80102e70 <outb>:
{
80102e70:	55                   	push   %ebp
80102e71:	89 e5                	mov    %esp,%ebp
80102e73:	83 ec 08             	sub    $0x8,%esp
80102e76:	8b 55 08             	mov    0x8(%ebp),%edx
80102e79:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e7c:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102e80:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e83:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102e87:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102e8b:	ee                   	out    %al,(%dx)
}
80102e8c:	90                   	nop
80102e8d:	c9                   	leave
80102e8e:	c3                   	ret

80102e8f <readeflags>:
{
80102e8f:	55                   	push   %ebp
80102e90:	89 e5                	mov    %esp,%ebp
80102e92:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102e95:	9c                   	pushf
80102e96:	58                   	pop    %eax
80102e97:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102e9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102e9d:	c9                   	leave
80102e9e:	c3                   	ret

80102e9f <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102e9f:	55                   	push   %ebp
80102ea0:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102ea2:	a1 20 12 11 80       	mov    0x80111220,%eax
80102ea7:	8b 55 08             	mov    0x8(%ebp),%edx
80102eaa:	c1 e2 02             	shl    $0x2,%edx
80102ead:	01 c2                	add    %eax,%edx
80102eaf:	8b 45 0c             	mov    0xc(%ebp),%eax
80102eb2:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102eb4:	a1 20 12 11 80       	mov    0x80111220,%eax
80102eb9:	83 c0 20             	add    $0x20,%eax
80102ebc:	8b 00                	mov    (%eax),%eax
}
80102ebe:	90                   	nop
80102ebf:	5d                   	pop    %ebp
80102ec0:	c3                   	ret

80102ec1 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102ec1:	55                   	push   %ebp
80102ec2:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102ec4:	a1 20 12 11 80       	mov    0x80111220,%eax
80102ec9:	85 c0                	test   %eax,%eax
80102ecb:	0f 84 09 01 00 00    	je     80102fda <lapicinit+0x119>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ed1:	68 3f 01 00 00       	push   $0x13f
80102ed6:	6a 3c                	push   $0x3c
80102ed8:	e8 c2 ff ff ff       	call   80102e9f <lapicw>
80102edd:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102ee0:	6a 0b                	push   $0xb
80102ee2:	68 f8 00 00 00       	push   $0xf8
80102ee7:	e8 b3 ff ff ff       	call   80102e9f <lapicw>
80102eec:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102eef:	68 20 00 02 00       	push   $0x20020
80102ef4:	68 c8 00 00 00       	push   $0xc8
80102ef9:	e8 a1 ff ff ff       	call   80102e9f <lapicw>
80102efe:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80102f01:	68 80 96 98 00       	push   $0x989680
80102f06:	68 e0 00 00 00       	push   $0xe0
80102f0b:	e8 8f ff ff ff       	call   80102e9f <lapicw>
80102f10:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f13:	68 00 00 01 00       	push   $0x10000
80102f18:	68 d4 00 00 00       	push   $0xd4
80102f1d:	e8 7d ff ff ff       	call   80102e9f <lapicw>
80102f22:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f25:	68 00 00 01 00       	push   $0x10000
80102f2a:	68 d8 00 00 00       	push   $0xd8
80102f2f:	e8 6b ff ff ff       	call   80102e9f <lapicw>
80102f34:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f37:	a1 20 12 11 80       	mov    0x80111220,%eax
80102f3c:	83 c0 30             	add    $0x30,%eax
80102f3f:	8b 00                	mov    (%eax),%eax
80102f41:	25 00 00 fc 00       	and    $0xfc0000,%eax
80102f46:	85 c0                	test   %eax,%eax
80102f48:	74 12                	je     80102f5c <lapicinit+0x9b>
    lapicw(PCINT, MASKED);
80102f4a:	68 00 00 01 00       	push   $0x10000
80102f4f:	68 d0 00 00 00       	push   $0xd0
80102f54:	e8 46 ff ff ff       	call   80102e9f <lapicw>
80102f59:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f5c:	6a 33                	push   $0x33
80102f5e:	68 dc 00 00 00       	push   $0xdc
80102f63:	e8 37 ff ff ff       	call   80102e9f <lapicw>
80102f68:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f6b:	6a 00                	push   $0x0
80102f6d:	68 a0 00 00 00       	push   $0xa0
80102f72:	e8 28 ff ff ff       	call   80102e9f <lapicw>
80102f77:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f7a:	6a 00                	push   $0x0
80102f7c:	68 a0 00 00 00       	push   $0xa0
80102f81:	e8 19 ff ff ff       	call   80102e9f <lapicw>
80102f86:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f89:	6a 00                	push   $0x0
80102f8b:	6a 2c                	push   $0x2c
80102f8d:	e8 0d ff ff ff       	call   80102e9f <lapicw>
80102f92:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f95:	6a 00                	push   $0x0
80102f97:	68 c4 00 00 00       	push   $0xc4
80102f9c:	e8 fe fe ff ff       	call   80102e9f <lapicw>
80102fa1:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102fa4:	68 00 85 08 00       	push   $0x88500
80102fa9:	68 c0 00 00 00       	push   $0xc0
80102fae:	e8 ec fe ff ff       	call   80102e9f <lapicw>
80102fb3:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102fb6:	90                   	nop
80102fb7:	a1 20 12 11 80       	mov    0x80111220,%eax
80102fbc:	05 00 03 00 00       	add    $0x300,%eax
80102fc1:	8b 00                	mov    (%eax),%eax
80102fc3:	25 00 10 00 00       	and    $0x1000,%eax
80102fc8:	85 c0                	test   %eax,%eax
80102fca:	75 eb                	jne    80102fb7 <lapicinit+0xf6>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fcc:	6a 00                	push   $0x0
80102fce:	6a 20                	push   $0x20
80102fd0:	e8 ca fe ff ff       	call   80102e9f <lapicw>
80102fd5:	83 c4 08             	add    $0x8,%esp
80102fd8:	eb 01                	jmp    80102fdb <lapicinit+0x11a>
    return;
80102fda:	90                   	nop
}
80102fdb:	c9                   	leave
80102fdc:	c3                   	ret

80102fdd <cpunum>:

int
cpunum(void)
{
80102fdd:	55                   	push   %ebp
80102fde:	89 e5                	mov    %esp,%ebp
80102fe0:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102fe3:	e8 a7 fe ff ff       	call   80102e8f <readeflags>
80102fe8:	25 00 02 00 00       	and    $0x200,%eax
80102fed:	85 c0                	test   %eax,%eax
80102fef:	74 26                	je     80103017 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80102ff1:	a1 24 12 11 80       	mov    0x80111224,%eax
80102ff6:	8d 50 01             	lea    0x1(%eax),%edx
80102ff9:	89 15 24 12 11 80    	mov    %edx,0x80111224
80102fff:	85 c0                	test   %eax,%eax
80103001:	75 14                	jne    80103017 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80103003:	8b 45 04             	mov    0x4(%ebp),%eax
80103006:	83 ec 08             	sub    $0x8,%esp
80103009:	50                   	push   %eax
8010300a:	68 bc 87 10 80       	push   $0x801087bc
8010300f:	e8 b0 d3 ff ff       	call   801003c4 <cprintf>
80103014:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80103017:	a1 20 12 11 80       	mov    0x80111220,%eax
8010301c:	85 c0                	test   %eax,%eax
8010301e:	74 0f                	je     8010302f <cpunum+0x52>
    return lapic[ID]>>24;
80103020:	a1 20 12 11 80       	mov    0x80111220,%eax
80103025:	83 c0 20             	add    $0x20,%eax
80103028:	8b 00                	mov    (%eax),%eax
8010302a:	c1 e8 18             	shr    $0x18,%eax
8010302d:	eb 05                	jmp    80103034 <cpunum+0x57>
  return 0;
8010302f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103034:	c9                   	leave
80103035:	c3                   	ret

80103036 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103036:	55                   	push   %ebp
80103037:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103039:	a1 20 12 11 80       	mov    0x80111220,%eax
8010303e:	85 c0                	test   %eax,%eax
80103040:	74 0c                	je     8010304e <lapiceoi+0x18>
    lapicw(EOI, 0);
80103042:	6a 00                	push   $0x0
80103044:	6a 2c                	push   $0x2c
80103046:	e8 54 fe ff ff       	call   80102e9f <lapicw>
8010304b:	83 c4 08             	add    $0x8,%esp
}
8010304e:	90                   	nop
8010304f:	c9                   	leave
80103050:	c3                   	ret

80103051 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103051:	55                   	push   %ebp
80103052:	89 e5                	mov    %esp,%ebp
}
80103054:	90                   	nop
80103055:	5d                   	pop    %ebp
80103056:	c3                   	ret

80103057 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103057:	55                   	push   %ebp
80103058:	89 e5                	mov    %esp,%ebp
8010305a:	83 ec 14             	sub    $0x14,%esp
8010305d:	8b 45 08             	mov    0x8(%ebp),%eax
80103060:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103063:	6a 0f                	push   $0xf
80103065:	6a 70                	push   $0x70
80103067:	e8 04 fe ff ff       	call   80102e70 <outb>
8010306c:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
8010306f:	6a 0a                	push   $0xa
80103071:	6a 71                	push   $0x71
80103073:	e8 f8 fd ff ff       	call   80102e70 <outb>
80103078:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010307b:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103082:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103085:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010308a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010308d:	c1 e8 04             	shr    $0x4,%eax
80103090:	89 c2                	mov    %eax,%edx
80103092:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103095:	83 c0 02             	add    $0x2,%eax
80103098:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010309b:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010309f:	c1 e0 18             	shl    $0x18,%eax
801030a2:	50                   	push   %eax
801030a3:	68 c4 00 00 00       	push   $0xc4
801030a8:	e8 f2 fd ff ff       	call   80102e9f <lapicw>
801030ad:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801030b0:	68 00 c5 00 00       	push   $0xc500
801030b5:	68 c0 00 00 00       	push   $0xc0
801030ba:	e8 e0 fd ff ff       	call   80102e9f <lapicw>
801030bf:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801030c2:	68 c8 00 00 00       	push   $0xc8
801030c7:	e8 85 ff ff ff       	call   80103051 <microdelay>
801030cc:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801030cf:	68 00 85 00 00       	push   $0x8500
801030d4:	68 c0 00 00 00       	push   $0xc0
801030d9:	e8 c1 fd ff ff       	call   80102e9f <lapicw>
801030de:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030e1:	6a 64                	push   $0x64
801030e3:	e8 69 ff ff ff       	call   80103051 <microdelay>
801030e8:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030eb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030f2:	eb 3d                	jmp    80103131 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
801030f4:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030f8:	c1 e0 18             	shl    $0x18,%eax
801030fb:	50                   	push   %eax
801030fc:	68 c4 00 00 00       	push   $0xc4
80103101:	e8 99 fd ff ff       	call   80102e9f <lapicw>
80103106:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103109:	8b 45 0c             	mov    0xc(%ebp),%eax
8010310c:	c1 e8 0c             	shr    $0xc,%eax
8010310f:	80 cc 06             	or     $0x6,%ah
80103112:	50                   	push   %eax
80103113:	68 c0 00 00 00       	push   $0xc0
80103118:	e8 82 fd ff ff       	call   80102e9f <lapicw>
8010311d:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103120:	68 c8 00 00 00       	push   $0xc8
80103125:	e8 27 ff ff ff       	call   80103051 <microdelay>
8010312a:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
8010312d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103131:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103135:	7e bd                	jle    801030f4 <lapicstartap+0x9d>
  }
}
80103137:	90                   	nop
80103138:	90                   	nop
80103139:	c9                   	leave
8010313a:	c3                   	ret

8010313b <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010313b:	55                   	push   %ebp
8010313c:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
8010313e:	8b 45 08             	mov    0x8(%ebp),%eax
80103141:	0f b6 c0             	movzbl %al,%eax
80103144:	50                   	push   %eax
80103145:	6a 70                	push   $0x70
80103147:	e8 24 fd ff ff       	call   80102e70 <outb>
8010314c:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010314f:	68 c8 00 00 00       	push   $0xc8
80103154:	e8 f8 fe ff ff       	call   80103051 <microdelay>
80103159:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
8010315c:	6a 71                	push   $0x71
8010315e:	e8 f0 fc ff ff       	call   80102e53 <inb>
80103163:	83 c4 04             	add    $0x4,%esp
80103166:	0f b6 c0             	movzbl %al,%eax
}
80103169:	c9                   	leave
8010316a:	c3                   	ret

8010316b <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010316b:	55                   	push   %ebp
8010316c:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
8010316e:	6a 00                	push   $0x0
80103170:	e8 c6 ff ff ff       	call   8010313b <cmos_read>
80103175:	83 c4 04             	add    $0x4,%esp
80103178:	8b 55 08             	mov    0x8(%ebp),%edx
8010317b:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
8010317d:	6a 02                	push   $0x2
8010317f:	e8 b7 ff ff ff       	call   8010313b <cmos_read>
80103184:	83 c4 04             	add    $0x4,%esp
80103187:	8b 55 08             	mov    0x8(%ebp),%edx
8010318a:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
8010318d:	6a 04                	push   $0x4
8010318f:	e8 a7 ff ff ff       	call   8010313b <cmos_read>
80103194:	83 c4 04             	add    $0x4,%esp
80103197:	8b 55 08             	mov    0x8(%ebp),%edx
8010319a:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
8010319d:	6a 07                	push   $0x7
8010319f:	e8 97 ff ff ff       	call   8010313b <cmos_read>
801031a4:	83 c4 04             	add    $0x4,%esp
801031a7:	8b 55 08             	mov    0x8(%ebp),%edx
801031aa:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801031ad:	6a 08                	push   $0x8
801031af:	e8 87 ff ff ff       	call   8010313b <cmos_read>
801031b4:	83 c4 04             	add    $0x4,%esp
801031b7:	8b 55 08             	mov    0x8(%ebp),%edx
801031ba:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801031bd:	6a 09                	push   $0x9
801031bf:	e8 77 ff ff ff       	call   8010313b <cmos_read>
801031c4:	83 c4 04             	add    $0x4,%esp
801031c7:	8b 55 08             	mov    0x8(%ebp),%edx
801031ca:	89 42 14             	mov    %eax,0x14(%edx)
}
801031cd:	90                   	nop
801031ce:	c9                   	leave
801031cf:	c3                   	ret

801031d0 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801031d0:	55                   	push   %ebp
801031d1:	89 e5                	mov    %esp,%ebp
801031d3:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031d6:	6a 0b                	push   $0xb
801031d8:	e8 5e ff ff ff       	call   8010313b <cmos_read>
801031dd:	83 c4 04             	add    $0x4,%esp
801031e0:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031e6:	83 e0 04             	and    $0x4,%eax
801031e9:	85 c0                	test   %eax,%eax
801031eb:	0f 94 c0             	sete   %al
801031ee:	0f b6 c0             	movzbl %al,%eax
801031f1:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801031f4:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031f7:	50                   	push   %eax
801031f8:	e8 6e ff ff ff       	call   8010316b <fill_rtcdate>
801031fd:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103200:	6a 0a                	push   $0xa
80103202:	e8 34 ff ff ff       	call   8010313b <cmos_read>
80103207:	83 c4 04             	add    $0x4,%esp
8010320a:	25 80 00 00 00       	and    $0x80,%eax
8010320f:	85 c0                	test   %eax,%eax
80103211:	75 27                	jne    8010323a <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80103213:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103216:	50                   	push   %eax
80103217:	e8 4f ff ff ff       	call   8010316b <fill_rtcdate>
8010321c:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
8010321f:	83 ec 04             	sub    $0x4,%esp
80103222:	6a 18                	push   $0x18
80103224:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103227:	50                   	push   %eax
80103228:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010322b:	50                   	push   %eax
8010322c:	e8 df 20 00 00       	call   80105310 <memcmp>
80103231:	83 c4 10             	add    $0x10,%esp
80103234:	85 c0                	test   %eax,%eax
80103236:	74 05                	je     8010323d <cmostime+0x6d>
80103238:	eb ba                	jmp    801031f4 <cmostime+0x24>
        continue;
8010323a:	90                   	nop
    fill_rtcdate(&t1);
8010323b:	eb b7                	jmp    801031f4 <cmostime+0x24>
      break;
8010323d:	90                   	nop
  }

  // convert
  if (bcd) {
8010323e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103242:	0f 84 b4 00 00 00    	je     801032fc <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103248:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010324b:	c1 e8 04             	shr    $0x4,%eax
8010324e:	89 c2                	mov    %eax,%edx
80103250:	89 d0                	mov    %edx,%eax
80103252:	c1 e0 02             	shl    $0x2,%eax
80103255:	01 d0                	add    %edx,%eax
80103257:	01 c0                	add    %eax,%eax
80103259:	89 c2                	mov    %eax,%edx
8010325b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010325e:	83 e0 0f             	and    $0xf,%eax
80103261:	01 d0                	add    %edx,%eax
80103263:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103266:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103269:	c1 e8 04             	shr    $0x4,%eax
8010326c:	89 c2                	mov    %eax,%edx
8010326e:	89 d0                	mov    %edx,%eax
80103270:	c1 e0 02             	shl    $0x2,%eax
80103273:	01 d0                	add    %edx,%eax
80103275:	01 c0                	add    %eax,%eax
80103277:	89 c2                	mov    %eax,%edx
80103279:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010327c:	83 e0 0f             	and    $0xf,%eax
8010327f:	01 d0                	add    %edx,%eax
80103281:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103284:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103287:	c1 e8 04             	shr    $0x4,%eax
8010328a:	89 c2                	mov    %eax,%edx
8010328c:	89 d0                	mov    %edx,%eax
8010328e:	c1 e0 02             	shl    $0x2,%eax
80103291:	01 d0                	add    %edx,%eax
80103293:	01 c0                	add    %eax,%eax
80103295:	89 c2                	mov    %eax,%edx
80103297:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010329a:	83 e0 0f             	and    $0xf,%eax
8010329d:	01 d0                	add    %edx,%eax
8010329f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801032a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032a5:	c1 e8 04             	shr    $0x4,%eax
801032a8:	89 c2                	mov    %eax,%edx
801032aa:	89 d0                	mov    %edx,%eax
801032ac:	c1 e0 02             	shl    $0x2,%eax
801032af:	01 d0                	add    %edx,%eax
801032b1:	01 c0                	add    %eax,%eax
801032b3:	89 c2                	mov    %eax,%edx
801032b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032b8:	83 e0 0f             	and    $0xf,%eax
801032bb:	01 d0                	add    %edx,%eax
801032bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801032c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032c3:	c1 e8 04             	shr    $0x4,%eax
801032c6:	89 c2                	mov    %eax,%edx
801032c8:	89 d0                	mov    %edx,%eax
801032ca:	c1 e0 02             	shl    $0x2,%eax
801032cd:	01 d0                	add    %edx,%eax
801032cf:	01 c0                	add    %eax,%eax
801032d1:	89 c2                	mov    %eax,%edx
801032d3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032d6:	83 e0 0f             	and    $0xf,%eax
801032d9:	01 d0                	add    %edx,%eax
801032db:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032de:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032e1:	c1 e8 04             	shr    $0x4,%eax
801032e4:	89 c2                	mov    %eax,%edx
801032e6:	89 d0                	mov    %edx,%eax
801032e8:	c1 e0 02             	shl    $0x2,%eax
801032eb:	01 d0                	add    %edx,%eax
801032ed:	01 c0                	add    %eax,%eax
801032ef:	89 c2                	mov    %eax,%edx
801032f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032f4:	83 e0 0f             	and    $0xf,%eax
801032f7:	01 d0                	add    %edx,%eax
801032f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801032fc:	8b 45 08             	mov    0x8(%ebp),%eax
801032ff:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103302:	89 10                	mov    %edx,(%eax)
80103304:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103307:	89 50 04             	mov    %edx,0x4(%eax)
8010330a:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010330d:	89 50 08             	mov    %edx,0x8(%eax)
80103310:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103313:	89 50 0c             	mov    %edx,0xc(%eax)
80103316:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103319:	89 50 10             	mov    %edx,0x10(%eax)
8010331c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010331f:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103322:	8b 45 08             	mov    0x8(%ebp),%eax
80103325:	8b 40 14             	mov    0x14(%eax),%eax
80103328:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010332e:	8b 45 08             	mov    0x8(%ebp),%eax
80103331:	89 50 14             	mov    %edx,0x14(%eax)
}
80103334:	90                   	nop
80103335:	c9                   	leave
80103336:	c3                   	ret

80103337 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103337:	55                   	push   %ebp
80103338:	89 e5                	mov    %esp,%ebp
8010333a:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010333d:	83 ec 08             	sub    $0x8,%esp
80103340:	68 e8 87 10 80       	push   $0x801087e8
80103345:	68 40 12 11 80       	push   $0x80111240
8010334a:	e8 d4 1c 00 00       	call   80105023 <initlock>
8010334f:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80103352:	83 ec 08             	sub    $0x8,%esp
80103355:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103358:	50                   	push   %eax
80103359:	ff 75 08             	push   0x8(%ebp)
8010335c:	e8 54 e0 ff ff       	call   801013b5 <readsb>
80103361:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103364:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103367:	a3 74 12 11 80       	mov    %eax,0x80111274
  log.size = sb.nlog;
8010336c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010336f:	a3 78 12 11 80       	mov    %eax,0x80111278
  log.dev = dev;
80103374:	8b 45 08             	mov    0x8(%ebp),%eax
80103377:	a3 84 12 11 80       	mov    %eax,0x80111284
  recover_from_log();
8010337c:	e8 b3 01 00 00       	call   80103534 <recover_from_log>
}
80103381:	90                   	nop
80103382:	c9                   	leave
80103383:	c3                   	ret

80103384 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103384:	55                   	push   %ebp
80103385:	89 e5                	mov    %esp,%ebp
80103387:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010338a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103391:	e9 95 00 00 00       	jmp    8010342b <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103396:	8b 15 74 12 11 80    	mov    0x80111274,%edx
8010339c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010339f:	01 d0                	add    %edx,%eax
801033a1:	83 c0 01             	add    $0x1,%eax
801033a4:	89 c2                	mov    %eax,%edx
801033a6:	a1 84 12 11 80       	mov    0x80111284,%eax
801033ab:	83 ec 08             	sub    $0x8,%esp
801033ae:	52                   	push   %edx
801033af:	50                   	push   %eax
801033b0:	e8 02 ce ff ff       	call   801001b7 <bread>
801033b5:	83 c4 10             	add    $0x10,%esp
801033b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801033bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033be:	83 c0 10             	add    $0x10,%eax
801033c1:	8b 04 85 4c 12 11 80 	mov    -0x7feeedb4(,%eax,4),%eax
801033c8:	89 c2                	mov    %eax,%edx
801033ca:	a1 84 12 11 80       	mov    0x80111284,%eax
801033cf:	83 ec 08             	sub    $0x8,%esp
801033d2:	52                   	push   %edx
801033d3:	50                   	push   %eax
801033d4:	e8 de cd ff ff       	call   801001b7 <bread>
801033d9:	83 c4 10             	add    $0x10,%esp
801033dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033e2:	8d 50 18             	lea    0x18(%eax),%edx
801033e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033e8:	83 c0 18             	add    $0x18,%eax
801033eb:	83 ec 04             	sub    $0x4,%esp
801033ee:	68 00 02 00 00       	push   $0x200
801033f3:	52                   	push   %edx
801033f4:	50                   	push   %eax
801033f5:	e8 6e 1f 00 00       	call   80105368 <memmove>
801033fa:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801033fd:	83 ec 0c             	sub    $0xc,%esp
80103400:	ff 75 ec             	push   -0x14(%ebp)
80103403:	e8 e8 cd ff ff       	call   801001f0 <bwrite>
80103408:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
8010340b:	83 ec 0c             	sub    $0xc,%esp
8010340e:	ff 75 f0             	push   -0x10(%ebp)
80103411:	e8 19 ce ff ff       	call   8010022f <brelse>
80103416:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103419:	83 ec 0c             	sub    $0xc,%esp
8010341c:	ff 75 ec             	push   -0x14(%ebp)
8010341f:	e8 0b ce ff ff       	call   8010022f <brelse>
80103424:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103427:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010342b:	a1 88 12 11 80       	mov    0x80111288,%eax
80103430:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103433:	0f 8c 5d ff ff ff    	jl     80103396 <install_trans+0x12>
  }
}
80103439:	90                   	nop
8010343a:	90                   	nop
8010343b:	c9                   	leave
8010343c:	c3                   	ret

8010343d <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010343d:	55                   	push   %ebp
8010343e:	89 e5                	mov    %esp,%ebp
80103440:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103443:	a1 74 12 11 80       	mov    0x80111274,%eax
80103448:	89 c2                	mov    %eax,%edx
8010344a:	a1 84 12 11 80       	mov    0x80111284,%eax
8010344f:	83 ec 08             	sub    $0x8,%esp
80103452:	52                   	push   %edx
80103453:	50                   	push   %eax
80103454:	e8 5e cd ff ff       	call   801001b7 <bread>
80103459:	83 c4 10             	add    $0x10,%esp
8010345c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010345f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103462:	83 c0 18             	add    $0x18,%eax
80103465:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103468:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010346b:	8b 00                	mov    (%eax),%eax
8010346d:	a3 88 12 11 80       	mov    %eax,0x80111288
  for (i = 0; i < log.lh.n; i++) {
80103472:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103479:	eb 1b                	jmp    80103496 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
8010347b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010347e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103481:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103485:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103488:	83 c2 10             	add    $0x10,%edx
8010348b:	89 04 95 4c 12 11 80 	mov    %eax,-0x7feeedb4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103492:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103496:	a1 88 12 11 80       	mov    0x80111288,%eax
8010349b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010349e:	7c db                	jl     8010347b <read_head+0x3e>
  }
  brelse(buf);
801034a0:	83 ec 0c             	sub    $0xc,%esp
801034a3:	ff 75 f0             	push   -0x10(%ebp)
801034a6:	e8 84 cd ff ff       	call   8010022f <brelse>
801034ab:	83 c4 10             	add    $0x10,%esp
}
801034ae:	90                   	nop
801034af:	c9                   	leave
801034b0:	c3                   	ret

801034b1 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801034b1:	55                   	push   %ebp
801034b2:	89 e5                	mov    %esp,%ebp
801034b4:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801034b7:	a1 74 12 11 80       	mov    0x80111274,%eax
801034bc:	89 c2                	mov    %eax,%edx
801034be:	a1 84 12 11 80       	mov    0x80111284,%eax
801034c3:	83 ec 08             	sub    $0x8,%esp
801034c6:	52                   	push   %edx
801034c7:	50                   	push   %eax
801034c8:	e8 ea cc ff ff       	call   801001b7 <bread>
801034cd:	83 c4 10             	add    $0x10,%esp
801034d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034d6:	83 c0 18             	add    $0x18,%eax
801034d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034dc:	8b 15 88 12 11 80    	mov    0x80111288,%edx
801034e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034e5:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034e7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034ee:	eb 1b                	jmp    8010350b <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
801034f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034f3:	83 c0 10             	add    $0x10,%eax
801034f6:	8b 0c 85 4c 12 11 80 	mov    -0x7feeedb4(,%eax,4),%ecx
801034fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103500:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103503:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103507:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010350b:	a1 88 12 11 80       	mov    0x80111288,%eax
80103510:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103513:	7c db                	jl     801034f0 <write_head+0x3f>
  }
  bwrite(buf);
80103515:	83 ec 0c             	sub    $0xc,%esp
80103518:	ff 75 f0             	push   -0x10(%ebp)
8010351b:	e8 d0 cc ff ff       	call   801001f0 <bwrite>
80103520:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103523:	83 ec 0c             	sub    $0xc,%esp
80103526:	ff 75 f0             	push   -0x10(%ebp)
80103529:	e8 01 cd ff ff       	call   8010022f <brelse>
8010352e:	83 c4 10             	add    $0x10,%esp
}
80103531:	90                   	nop
80103532:	c9                   	leave
80103533:	c3                   	ret

80103534 <recover_from_log>:

static void
recover_from_log(void)
{
80103534:	55                   	push   %ebp
80103535:	89 e5                	mov    %esp,%ebp
80103537:	83 ec 08             	sub    $0x8,%esp
  read_head();      
8010353a:	e8 fe fe ff ff       	call   8010343d <read_head>
  install_trans(); // if committed, copy from log to disk
8010353f:	e8 40 fe ff ff       	call   80103384 <install_trans>
  log.lh.n = 0;
80103544:	c7 05 88 12 11 80 00 	movl   $0x0,0x80111288
8010354b:	00 00 00 
  write_head(); // clear the log
8010354e:	e8 5e ff ff ff       	call   801034b1 <write_head>
}
80103553:	90                   	nop
80103554:	c9                   	leave
80103555:	c3                   	ret

80103556 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103556:	55                   	push   %ebp
80103557:	89 e5                	mov    %esp,%ebp
80103559:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010355c:	83 ec 0c             	sub    $0xc,%esp
8010355f:	68 40 12 11 80       	push   $0x80111240
80103564:	e8 dc 1a 00 00       	call   80105045 <acquire>
80103569:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010356c:	a1 80 12 11 80       	mov    0x80111280,%eax
80103571:	85 c0                	test   %eax,%eax
80103573:	74 17                	je     8010358c <begin_op+0x36>
      sleep(&log, &log.lock);
80103575:	83 ec 08             	sub    $0x8,%esp
80103578:	68 40 12 11 80       	push   $0x80111240
8010357d:	68 40 12 11 80       	push   $0x80111240
80103582:	e8 c3 17 00 00       	call   80104d4a <sleep>
80103587:	83 c4 10             	add    $0x10,%esp
8010358a:	eb e0                	jmp    8010356c <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010358c:	8b 0d 88 12 11 80    	mov    0x80111288,%ecx
80103592:	a1 7c 12 11 80       	mov    0x8011127c,%eax
80103597:	8d 50 01             	lea    0x1(%eax),%edx
8010359a:	89 d0                	mov    %edx,%eax
8010359c:	c1 e0 02             	shl    $0x2,%eax
8010359f:	01 d0                	add    %edx,%eax
801035a1:	01 c0                	add    %eax,%eax
801035a3:	01 c8                	add    %ecx,%eax
801035a5:	83 f8 1e             	cmp    $0x1e,%eax
801035a8:	7e 17                	jle    801035c1 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801035aa:	83 ec 08             	sub    $0x8,%esp
801035ad:	68 40 12 11 80       	push   $0x80111240
801035b2:	68 40 12 11 80       	push   $0x80111240
801035b7:	e8 8e 17 00 00       	call   80104d4a <sleep>
801035bc:	83 c4 10             	add    $0x10,%esp
801035bf:	eb ab                	jmp    8010356c <begin_op+0x16>
    } else {
      log.outstanding += 1;
801035c1:	a1 7c 12 11 80       	mov    0x8011127c,%eax
801035c6:	83 c0 01             	add    $0x1,%eax
801035c9:	a3 7c 12 11 80       	mov    %eax,0x8011127c
      release(&log.lock);
801035ce:	83 ec 0c             	sub    $0xc,%esp
801035d1:	68 40 12 11 80       	push   $0x80111240
801035d6:	e8 d1 1a 00 00       	call   801050ac <release>
801035db:	83 c4 10             	add    $0x10,%esp
      break;
801035de:	90                   	nop
    }
  }
}
801035df:	90                   	nop
801035e0:	c9                   	leave
801035e1:	c3                   	ret

801035e2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035e2:	55                   	push   %ebp
801035e3:	89 e5                	mov    %esp,%ebp
801035e5:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801035e8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801035ef:	83 ec 0c             	sub    $0xc,%esp
801035f2:	68 40 12 11 80       	push   $0x80111240
801035f7:	e8 49 1a 00 00       	call   80105045 <acquire>
801035fc:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801035ff:	a1 7c 12 11 80       	mov    0x8011127c,%eax
80103604:	83 e8 01             	sub    $0x1,%eax
80103607:	a3 7c 12 11 80       	mov    %eax,0x8011127c
  if(log.committing)
8010360c:	a1 80 12 11 80       	mov    0x80111280,%eax
80103611:	85 c0                	test   %eax,%eax
80103613:	74 0d                	je     80103622 <end_op+0x40>
    panic("log.committing");
80103615:	83 ec 0c             	sub    $0xc,%esp
80103618:	68 ec 87 10 80       	push   $0x801087ec
8010361d:	e8 57 cf ff ff       	call   80100579 <panic>
  if(log.outstanding == 0){
80103622:	a1 7c 12 11 80       	mov    0x8011127c,%eax
80103627:	85 c0                	test   %eax,%eax
80103629:	75 13                	jne    8010363e <end_op+0x5c>
    do_commit = 1;
8010362b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103632:	c7 05 80 12 11 80 01 	movl   $0x1,0x80111280
80103639:	00 00 00 
8010363c:	eb 10                	jmp    8010364e <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
8010363e:	83 ec 0c             	sub    $0xc,%esp
80103641:	68 40 12 11 80       	push   $0x80111240
80103646:	e8 eb 17 00 00       	call   80104e36 <wakeup>
8010364b:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
8010364e:	83 ec 0c             	sub    $0xc,%esp
80103651:	68 40 12 11 80       	push   $0x80111240
80103656:	e8 51 1a 00 00       	call   801050ac <release>
8010365b:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
8010365e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103662:	74 3f                	je     801036a3 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103664:	e8 f6 00 00 00       	call   8010375f <commit>
    acquire(&log.lock);
80103669:	83 ec 0c             	sub    $0xc,%esp
8010366c:	68 40 12 11 80       	push   $0x80111240
80103671:	e8 cf 19 00 00       	call   80105045 <acquire>
80103676:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103679:	c7 05 80 12 11 80 00 	movl   $0x0,0x80111280
80103680:	00 00 00 
    wakeup(&log);
80103683:	83 ec 0c             	sub    $0xc,%esp
80103686:	68 40 12 11 80       	push   $0x80111240
8010368b:	e8 a6 17 00 00       	call   80104e36 <wakeup>
80103690:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
80103693:	83 ec 0c             	sub    $0xc,%esp
80103696:	68 40 12 11 80       	push   $0x80111240
8010369b:	e8 0c 1a 00 00       	call   801050ac <release>
801036a0:	83 c4 10             	add    $0x10,%esp
  }
}
801036a3:	90                   	nop
801036a4:	c9                   	leave
801036a5:	c3                   	ret

801036a6 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
801036a6:	55                   	push   %ebp
801036a7:	89 e5                	mov    %esp,%ebp
801036a9:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036b3:	e9 95 00 00 00       	jmp    8010374d <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801036b8:	8b 15 74 12 11 80    	mov    0x80111274,%edx
801036be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036c1:	01 d0                	add    %edx,%eax
801036c3:	83 c0 01             	add    $0x1,%eax
801036c6:	89 c2                	mov    %eax,%edx
801036c8:	a1 84 12 11 80       	mov    0x80111284,%eax
801036cd:	83 ec 08             	sub    $0x8,%esp
801036d0:	52                   	push   %edx
801036d1:	50                   	push   %eax
801036d2:	e8 e0 ca ff ff       	call   801001b7 <bread>
801036d7:	83 c4 10             	add    $0x10,%esp
801036da:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036e0:	83 c0 10             	add    $0x10,%eax
801036e3:	8b 04 85 4c 12 11 80 	mov    -0x7feeedb4(,%eax,4),%eax
801036ea:	89 c2                	mov    %eax,%edx
801036ec:	a1 84 12 11 80       	mov    0x80111284,%eax
801036f1:	83 ec 08             	sub    $0x8,%esp
801036f4:	52                   	push   %edx
801036f5:	50                   	push   %eax
801036f6:	e8 bc ca ff ff       	call   801001b7 <bread>
801036fb:	83 c4 10             	add    $0x10,%esp
801036fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103701:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103704:	8d 50 18             	lea    0x18(%eax),%edx
80103707:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010370a:	83 c0 18             	add    $0x18,%eax
8010370d:	83 ec 04             	sub    $0x4,%esp
80103710:	68 00 02 00 00       	push   $0x200
80103715:	52                   	push   %edx
80103716:	50                   	push   %eax
80103717:	e8 4c 1c 00 00       	call   80105368 <memmove>
8010371c:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
8010371f:	83 ec 0c             	sub    $0xc,%esp
80103722:	ff 75 f0             	push   -0x10(%ebp)
80103725:	e8 c6 ca ff ff       	call   801001f0 <bwrite>
8010372a:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
8010372d:	83 ec 0c             	sub    $0xc,%esp
80103730:	ff 75 ec             	push   -0x14(%ebp)
80103733:	e8 f7 ca ff ff       	call   8010022f <brelse>
80103738:	83 c4 10             	add    $0x10,%esp
    brelse(to);
8010373b:	83 ec 0c             	sub    $0xc,%esp
8010373e:	ff 75 f0             	push   -0x10(%ebp)
80103741:	e8 e9 ca ff ff       	call   8010022f <brelse>
80103746:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103749:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010374d:	a1 88 12 11 80       	mov    0x80111288,%eax
80103752:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103755:	0f 8c 5d ff ff ff    	jl     801036b8 <write_log+0x12>
  }
}
8010375b:	90                   	nop
8010375c:	90                   	nop
8010375d:	c9                   	leave
8010375e:	c3                   	ret

8010375f <commit>:

static void
commit()
{
8010375f:	55                   	push   %ebp
80103760:	89 e5                	mov    %esp,%ebp
80103762:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103765:	a1 88 12 11 80       	mov    0x80111288,%eax
8010376a:	85 c0                	test   %eax,%eax
8010376c:	7e 1e                	jle    8010378c <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
8010376e:	e8 33 ff ff ff       	call   801036a6 <write_log>
    write_head();    // Write header to disk -- the real commit
80103773:	e8 39 fd ff ff       	call   801034b1 <write_head>
    install_trans(); // Now install writes to home locations
80103778:	e8 07 fc ff ff       	call   80103384 <install_trans>
    log.lh.n = 0; 
8010377d:	c7 05 88 12 11 80 00 	movl   $0x0,0x80111288
80103784:	00 00 00 
    write_head();    // Erase the transaction from the log
80103787:	e8 25 fd ff ff       	call   801034b1 <write_head>
  }
}
8010378c:	90                   	nop
8010378d:	c9                   	leave
8010378e:	c3                   	ret

8010378f <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010378f:	55                   	push   %ebp
80103790:	89 e5                	mov    %esp,%ebp
80103792:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103795:	a1 88 12 11 80       	mov    0x80111288,%eax
8010379a:	83 f8 1d             	cmp    $0x1d,%eax
8010379d:	7f 12                	jg     801037b1 <log_write+0x22>
8010379f:	8b 15 88 12 11 80    	mov    0x80111288,%edx
801037a5:	a1 78 12 11 80       	mov    0x80111278,%eax
801037aa:	83 e8 01             	sub    $0x1,%eax
801037ad:	39 c2                	cmp    %eax,%edx
801037af:	7c 0d                	jl     801037be <log_write+0x2f>
    panic("too big a transaction");
801037b1:	83 ec 0c             	sub    $0xc,%esp
801037b4:	68 fb 87 10 80       	push   $0x801087fb
801037b9:	e8 bb cd ff ff       	call   80100579 <panic>
  if (log.outstanding < 1)
801037be:	a1 7c 12 11 80       	mov    0x8011127c,%eax
801037c3:	85 c0                	test   %eax,%eax
801037c5:	7f 0d                	jg     801037d4 <log_write+0x45>
    panic("log_write outside of trans");
801037c7:	83 ec 0c             	sub    $0xc,%esp
801037ca:	68 11 88 10 80       	push   $0x80108811
801037cf:	e8 a5 cd ff ff       	call   80100579 <panic>

  acquire(&log.lock);
801037d4:	83 ec 0c             	sub    $0xc,%esp
801037d7:	68 40 12 11 80       	push   $0x80111240
801037dc:	e8 64 18 00 00       	call   80105045 <acquire>
801037e1:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037eb:	eb 1d                	jmp    8010380a <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801037ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037f0:	83 c0 10             	add    $0x10,%eax
801037f3:	8b 04 85 4c 12 11 80 	mov    -0x7feeedb4(,%eax,4),%eax
801037fa:	89 c2                	mov    %eax,%edx
801037fc:	8b 45 08             	mov    0x8(%ebp),%eax
801037ff:	8b 40 08             	mov    0x8(%eax),%eax
80103802:	39 c2                	cmp    %eax,%edx
80103804:	74 10                	je     80103816 <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
80103806:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010380a:	a1 88 12 11 80       	mov    0x80111288,%eax
8010380f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103812:	7c d9                	jl     801037ed <log_write+0x5e>
80103814:	eb 01                	jmp    80103817 <log_write+0x88>
      break;
80103816:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103817:	8b 45 08             	mov    0x8(%ebp),%eax
8010381a:	8b 40 08             	mov    0x8(%eax),%eax
8010381d:	89 c2                	mov    %eax,%edx
8010381f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103822:	83 c0 10             	add    $0x10,%eax
80103825:	89 14 85 4c 12 11 80 	mov    %edx,-0x7feeedb4(,%eax,4)
  if (i == log.lh.n)
8010382c:	a1 88 12 11 80       	mov    0x80111288,%eax
80103831:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103834:	75 0d                	jne    80103843 <log_write+0xb4>
    log.lh.n++;
80103836:	a1 88 12 11 80       	mov    0x80111288,%eax
8010383b:	83 c0 01             	add    $0x1,%eax
8010383e:	a3 88 12 11 80       	mov    %eax,0x80111288
  b->flags |= B_DIRTY; // prevent eviction
80103843:	8b 45 08             	mov    0x8(%ebp),%eax
80103846:	8b 00                	mov    (%eax),%eax
80103848:	83 c8 04             	or     $0x4,%eax
8010384b:	89 c2                	mov    %eax,%edx
8010384d:	8b 45 08             	mov    0x8(%ebp),%eax
80103850:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103852:	83 ec 0c             	sub    $0xc,%esp
80103855:	68 40 12 11 80       	push   $0x80111240
8010385a:	e8 4d 18 00 00       	call   801050ac <release>
8010385f:	83 c4 10             	add    $0x10,%esp
}
80103862:	90                   	nop
80103863:	c9                   	leave
80103864:	c3                   	ret

80103865 <v2p>:
80103865:	55                   	push   %ebp
80103866:	89 e5                	mov    %esp,%ebp
80103868:	8b 45 08             	mov    0x8(%ebp),%eax
8010386b:	05 00 00 00 80       	add    $0x80000000,%eax
80103870:	5d                   	pop    %ebp
80103871:	c3                   	ret

80103872 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103872:	55                   	push   %ebp
80103873:	89 e5                	mov    %esp,%ebp
80103875:	8b 45 08             	mov    0x8(%ebp),%eax
80103878:	05 00 00 00 80       	add    $0x80000000,%eax
8010387d:	5d                   	pop    %ebp
8010387e:	c3                   	ret

8010387f <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010387f:	55                   	push   %ebp
80103880:	89 e5                	mov    %esp,%ebp
80103882:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103885:	8b 55 08             	mov    0x8(%ebp),%edx
80103888:	8b 45 0c             	mov    0xc(%ebp),%eax
8010388b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010388e:	f0 87 02             	lock xchg %eax,(%edx)
80103891:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103894:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103897:	c9                   	leave
80103898:	c3                   	ret

80103899 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103899:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010389d:	83 e4 f0             	and    $0xfffffff0,%esp
801038a0:	ff 71 fc             	push   -0x4(%ecx)
801038a3:	55                   	push   %ebp
801038a4:	89 e5                	mov    %esp,%ebp
801038a6:	51                   	push   %ecx
801038a7:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801038aa:	83 ec 08             	sub    $0x8,%esp
801038ad:	68 00 00 40 80       	push   $0x80400000
801038b2:	68 00 51 11 80       	push   $0x80115100
801038b7:	e8 85 f2 ff ff       	call   80102b41 <kinit1>
801038bc:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801038bf:	e8 38 45 00 00       	call   80107dfc <kvmalloc>
  mpinit();        // collect info about this machine
801038c4:	e8 38 04 00 00       	call   80103d01 <mpinit>
  lapicinit();
801038c9:	e8 f3 f5 ff ff       	call   80102ec1 <lapicinit>
  seginit();       // set up segments
801038ce:	e8 d2 3e 00 00       	call   801077a5 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801038d3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038d9:	0f b6 00             	movzbl (%eax),%eax
801038dc:	0f b6 c0             	movzbl %al,%eax
801038df:	83 ec 08             	sub    $0x8,%esp
801038e2:	50                   	push   %eax
801038e3:	68 2c 88 10 80       	push   $0x8010882c
801038e8:	e8 d7 ca ff ff       	call   801003c4 <cprintf>
801038ed:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
801038f0:	e8 86 06 00 00       	call   80103f7b <picinit>
  ioapicinit();    // another interrupt controller
801038f5:	e8 3c f1 ff ff       	call   80102a36 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801038fa:	e8 4b d2 ff ff       	call   80100b4a <consoleinit>
  uartinit();      // serial port
801038ff:	e8 fd 31 00 00       	call   80106b01 <uartinit>
  pinit();         // process table
80103904:	e8 76 0b 00 00       	call   8010447f <pinit>
  tvinit();        // trap vectors
80103909:	e8 bc 2d 00 00       	call   801066ca <tvinit>
  binit();         // buffer cache
8010390e:	e8 21 c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103913:	e8 8e d6 ff ff       	call   80100fa6 <fileinit>
  ideinit();       // disk
80103918:	e8 21 ed ff ff       	call   8010263e <ideinit>
  if(!ismp)
8010391d:	a1 00 19 11 80       	mov    0x80111900,%eax
80103922:	85 c0                	test   %eax,%eax
80103924:	75 05                	jne    8010392b <main+0x92>
    timerinit();   // uniprocessor timer
80103926:	e8 fc 2c 00 00       	call   80106627 <timerinit>
  startothers();   // start other processors
8010392b:	e8 7f 00 00 00       	call   801039af <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103930:	83 ec 08             	sub    $0x8,%esp
80103933:	68 00 00 00 8e       	push   $0x8e000000
80103938:	68 00 00 40 80       	push   $0x80400000
8010393d:	e8 38 f2 ff ff       	call   80102b7a <kinit2>
80103942:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103945:	e8 57 0c 00 00       	call   801045a1 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
8010394a:	e8 1a 00 00 00       	call   80103969 <mpmain>

8010394f <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010394f:	55                   	push   %ebp
80103950:	89 e5                	mov    %esp,%ebp
80103952:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103955:	e8 ba 44 00 00       	call   80107e14 <switchkvm>
  seginit();
8010395a:	e8 46 3e 00 00       	call   801077a5 <seginit>
  lapicinit();
8010395f:	e8 5d f5 ff ff       	call   80102ec1 <lapicinit>
  mpmain();
80103964:	e8 00 00 00 00       	call   80103969 <mpmain>

80103969 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103969:	55                   	push   %ebp
8010396a:	89 e5                	mov    %esp,%ebp
8010396c:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010396f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103975:	0f b6 00             	movzbl (%eax),%eax
80103978:	0f b6 c0             	movzbl %al,%eax
8010397b:	83 ec 08             	sub    $0x8,%esp
8010397e:	50                   	push   %eax
8010397f:	68 43 88 10 80       	push   $0x80108843
80103984:	e8 3b ca ff ff       	call   801003c4 <cprintf>
80103989:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
8010398c:	e8 af 2e 00 00       	call   80106840 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
80103991:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103997:	05 a8 00 00 00       	add    $0xa8,%eax
8010399c:	83 ec 08             	sub    $0x8,%esp
8010399f:	6a 01                	push   $0x1
801039a1:	50                   	push   %eax
801039a2:	e8 d8 fe ff ff       	call   8010387f <xchg>
801039a7:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801039aa:	e8 95 11 00 00       	call   80104b44 <scheduler>

801039af <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801039af:	55                   	push   %ebp
801039b0:	89 e5                	mov    %esp,%ebp
801039b2:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801039b5:	68 00 70 00 00       	push   $0x7000
801039ba:	e8 b3 fe ff ff       	call   80103872 <p2v>
801039bf:	83 c4 04             	add    $0x4,%esp
801039c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801039c5:	b8 8a 00 00 00       	mov    $0x8a,%eax
801039ca:	83 ec 04             	sub    $0x4,%esp
801039cd:	50                   	push   %eax
801039ce:	68 0c b5 10 80       	push   $0x8010b50c
801039d3:	ff 75 f0             	push   -0x10(%ebp)
801039d6:	e8 8d 19 00 00       	call   80105368 <memmove>
801039db:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801039de:	c7 45 f4 20 13 11 80 	movl   $0x80111320,-0xc(%ebp)
801039e5:	e9 8e 00 00 00       	jmp    80103a78 <startothers+0xc9>
    if(c == cpus+cpunum())  // We've started already.
801039ea:	e8 ee f5 ff ff       	call   80102fdd <cpunum>
801039ef:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801039f5:	05 20 13 11 80       	add    $0x80111320,%eax
801039fa:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801039fd:	74 71                	je     80103a70 <startothers+0xc1>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801039ff:	e8 75 f2 ff ff       	call   80102c79 <kalloc>
80103a04:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103a07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a0a:	83 e8 04             	sub    $0x4,%eax
80103a0d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a10:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103a16:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103a18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a1b:	83 e8 08             	sub    $0x8,%eax
80103a1e:	c7 00 4f 39 10 80    	movl   $0x8010394f,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103a24:	83 ec 0c             	sub    $0xc,%esp
80103a27:	68 00 a0 10 80       	push   $0x8010a000
80103a2c:	e8 34 fe ff ff       	call   80103865 <v2p>
80103a31:	83 c4 10             	add    $0x10,%esp
80103a34:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103a37:	83 ea 0c             	sub    $0xc,%edx
80103a3a:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->id, v2p(code));
80103a3c:	83 ec 0c             	sub    $0xc,%esp
80103a3f:	ff 75 f0             	push   -0x10(%ebp)
80103a42:	e8 1e fe ff ff       	call   80103865 <v2p>
80103a47:	83 c4 10             	add    $0x10,%esp
80103a4a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103a4d:	0f b6 12             	movzbl (%edx),%edx
80103a50:	0f b6 d2             	movzbl %dl,%edx
80103a53:	83 ec 08             	sub    $0x8,%esp
80103a56:	50                   	push   %eax
80103a57:	52                   	push   %edx
80103a58:	e8 fa f5 ff ff       	call   80103057 <lapicstartap>
80103a5d:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a60:	90                   	nop
80103a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a64:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103a6a:	85 c0                	test   %eax,%eax
80103a6c:	74 f3                	je     80103a61 <startothers+0xb2>
80103a6e:	eb 01                	jmp    80103a71 <startothers+0xc2>
      continue;
80103a70:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103a71:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103a78:	a1 04 19 11 80       	mov    0x80111904,%eax
80103a7d:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a83:	05 20 13 11 80       	add    $0x80111320,%eax
80103a88:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a8b:	0f 82 59 ff ff ff    	jb     801039ea <startothers+0x3b>
      ;
  }
}
80103a91:	90                   	nop
80103a92:	90                   	nop
80103a93:	c9                   	leave
80103a94:	c3                   	ret

80103a95 <p2v>:
80103a95:	55                   	push   %ebp
80103a96:	89 e5                	mov    %esp,%ebp
80103a98:	8b 45 08             	mov    0x8(%ebp),%eax
80103a9b:	05 00 00 00 80       	add    $0x80000000,%eax
80103aa0:	5d                   	pop    %ebp
80103aa1:	c3                   	ret

80103aa2 <inb>:
{
80103aa2:	55                   	push   %ebp
80103aa3:	89 e5                	mov    %esp,%ebp
80103aa5:	83 ec 14             	sub    $0x14,%esp
80103aa8:	8b 45 08             	mov    0x8(%ebp),%eax
80103aab:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103aaf:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103ab3:	89 c2                	mov    %eax,%edx
80103ab5:	ec                   	in     (%dx),%al
80103ab6:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103ab9:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103abd:	c9                   	leave
80103abe:	c3                   	ret

80103abf <outb>:
{
80103abf:	55                   	push   %ebp
80103ac0:	89 e5                	mov    %esp,%ebp
80103ac2:	83 ec 08             	sub    $0x8,%esp
80103ac5:	8b 55 08             	mov    0x8(%ebp),%edx
80103ac8:	8b 45 0c             	mov    0xc(%ebp),%eax
80103acb:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103acf:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103ad2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ad6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103ada:	ee                   	out    %al,(%dx)
}
80103adb:	90                   	nop
80103adc:	c9                   	leave
80103add:	c3                   	ret

80103ade <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103ade:	55                   	push   %ebp
80103adf:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103ae1:	a1 0c 19 11 80       	mov    0x8011190c,%eax
80103ae6:	2d 20 13 11 80       	sub    $0x80111320,%eax
80103aeb:	c1 f8 02             	sar    $0x2,%eax
80103aee:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103af4:	5d                   	pop    %ebp
80103af5:	c3                   	ret

80103af6 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103af6:	55                   	push   %ebp
80103af7:	89 e5                	mov    %esp,%ebp
80103af9:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103afc:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b03:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103b0a:	eb 15                	jmp    80103b21 <sum+0x2b>
    sum += addr[i];
80103b0c:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b0f:	8b 45 08             	mov    0x8(%ebp),%eax
80103b12:	01 d0                	add    %edx,%eax
80103b14:	0f b6 00             	movzbl (%eax),%eax
80103b17:	0f b6 c0             	movzbl %al,%eax
80103b1a:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b1d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103b21:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103b24:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b27:	7c e3                	jl     80103b0c <sum+0x16>
  return sum;
80103b29:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b2c:	c9                   	leave
80103b2d:	c3                   	ret

80103b2e <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103b2e:	55                   	push   %ebp
80103b2f:	89 e5                	mov    %esp,%ebp
80103b31:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103b34:	ff 75 08             	push   0x8(%ebp)
80103b37:	e8 59 ff ff ff       	call   80103a95 <p2v>
80103b3c:	83 c4 04             	add    $0x4,%esp
80103b3f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103b42:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b48:	01 d0                	add    %edx,%eax
80103b4a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103b4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b50:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b53:	eb 36                	jmp    80103b8b <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103b55:	83 ec 04             	sub    $0x4,%esp
80103b58:	6a 04                	push   $0x4
80103b5a:	68 54 88 10 80       	push   $0x80108854
80103b5f:	ff 75 f4             	push   -0xc(%ebp)
80103b62:	e8 a9 17 00 00       	call   80105310 <memcmp>
80103b67:	83 c4 10             	add    $0x10,%esp
80103b6a:	85 c0                	test   %eax,%eax
80103b6c:	75 19                	jne    80103b87 <mpsearch1+0x59>
80103b6e:	83 ec 08             	sub    $0x8,%esp
80103b71:	6a 10                	push   $0x10
80103b73:	ff 75 f4             	push   -0xc(%ebp)
80103b76:	e8 7b ff ff ff       	call   80103af6 <sum>
80103b7b:	83 c4 10             	add    $0x10,%esp
80103b7e:	84 c0                	test   %al,%al
80103b80:	75 05                	jne    80103b87 <mpsearch1+0x59>
      return (struct mp*)p;
80103b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b85:	eb 11                	jmp    80103b98 <mpsearch1+0x6a>
  for(p = addr; p < e; p += sizeof(struct mp))
80103b87:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b8e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103b91:	72 c2                	jb     80103b55 <mpsearch1+0x27>
  return 0;
80103b93:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103b98:	c9                   	leave
80103b99:	c3                   	ret

80103b9a <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103b9a:	55                   	push   %ebp
80103b9b:	89 e5                	mov    %esp,%ebp
80103b9d:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103ba0:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103baa:	83 c0 0f             	add    $0xf,%eax
80103bad:	0f b6 00             	movzbl (%eax),%eax
80103bb0:	0f b6 c0             	movzbl %al,%eax
80103bb3:	c1 e0 08             	shl    $0x8,%eax
80103bb6:	89 c2                	mov    %eax,%edx
80103bb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbb:	83 c0 0e             	add    $0xe,%eax
80103bbe:	0f b6 00             	movzbl (%eax),%eax
80103bc1:	0f b6 c0             	movzbl %al,%eax
80103bc4:	09 d0                	or     %edx,%eax
80103bc6:	c1 e0 04             	shl    $0x4,%eax
80103bc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103bcc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103bd0:	74 21                	je     80103bf3 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103bd2:	83 ec 08             	sub    $0x8,%esp
80103bd5:	68 00 04 00 00       	push   $0x400
80103bda:	ff 75 f0             	push   -0x10(%ebp)
80103bdd:	e8 4c ff ff ff       	call   80103b2e <mpsearch1>
80103be2:	83 c4 10             	add    $0x10,%esp
80103be5:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103be8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103bec:	74 51                	je     80103c3f <mpsearch+0xa5>
      return mp;
80103bee:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bf1:	eb 61                	jmp    80103c54 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf6:	83 c0 14             	add    $0x14,%eax
80103bf9:	0f b6 00             	movzbl (%eax),%eax
80103bfc:	0f b6 c0             	movzbl %al,%eax
80103bff:	c1 e0 08             	shl    $0x8,%eax
80103c02:	89 c2                	mov    %eax,%edx
80103c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c07:	83 c0 13             	add    $0x13,%eax
80103c0a:	0f b6 00             	movzbl (%eax),%eax
80103c0d:	0f b6 c0             	movzbl %al,%eax
80103c10:	09 d0                	or     %edx,%eax
80103c12:	c1 e0 0a             	shl    $0xa,%eax
80103c15:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103c18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c1b:	2d 00 04 00 00       	sub    $0x400,%eax
80103c20:	83 ec 08             	sub    $0x8,%esp
80103c23:	68 00 04 00 00       	push   $0x400
80103c28:	50                   	push   %eax
80103c29:	e8 00 ff ff ff       	call   80103b2e <mpsearch1>
80103c2e:	83 c4 10             	add    $0x10,%esp
80103c31:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c34:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c38:	74 05                	je     80103c3f <mpsearch+0xa5>
      return mp;
80103c3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c3d:	eb 15                	jmp    80103c54 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103c3f:	83 ec 08             	sub    $0x8,%esp
80103c42:	68 00 00 01 00       	push   $0x10000
80103c47:	68 00 00 0f 00       	push   $0xf0000
80103c4c:	e8 dd fe ff ff       	call   80103b2e <mpsearch1>
80103c51:	83 c4 10             	add    $0x10,%esp
}
80103c54:	c9                   	leave
80103c55:	c3                   	ret

80103c56 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103c56:	55                   	push   %ebp
80103c57:	89 e5                	mov    %esp,%ebp
80103c59:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103c5c:	e8 39 ff ff ff       	call   80103b9a <mpsearch>
80103c61:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c64:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c68:	74 0a                	je     80103c74 <mpconfig+0x1e>
80103c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c6d:	8b 40 04             	mov    0x4(%eax),%eax
80103c70:	85 c0                	test   %eax,%eax
80103c72:	75 0a                	jne    80103c7e <mpconfig+0x28>
    return 0;
80103c74:	b8 00 00 00 00       	mov    $0x0,%eax
80103c79:	e9 81 00 00 00       	jmp    80103cff <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c81:	8b 40 04             	mov    0x4(%eax),%eax
80103c84:	83 ec 0c             	sub    $0xc,%esp
80103c87:	50                   	push   %eax
80103c88:	e8 08 fe ff ff       	call   80103a95 <p2v>
80103c8d:	83 c4 10             	add    $0x10,%esp
80103c90:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103c93:	83 ec 04             	sub    $0x4,%esp
80103c96:	6a 04                	push   $0x4
80103c98:	68 59 88 10 80       	push   $0x80108859
80103c9d:	ff 75 f0             	push   -0x10(%ebp)
80103ca0:	e8 6b 16 00 00       	call   80105310 <memcmp>
80103ca5:	83 c4 10             	add    $0x10,%esp
80103ca8:	85 c0                	test   %eax,%eax
80103caa:	74 07                	je     80103cb3 <mpconfig+0x5d>
    return 0;
80103cac:	b8 00 00 00 00       	mov    $0x0,%eax
80103cb1:	eb 4c                	jmp    80103cff <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103cb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb6:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103cba:	3c 01                	cmp    $0x1,%al
80103cbc:	74 12                	je     80103cd0 <mpconfig+0x7a>
80103cbe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cc1:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103cc5:	3c 04                	cmp    $0x4,%al
80103cc7:	74 07                	je     80103cd0 <mpconfig+0x7a>
    return 0;
80103cc9:	b8 00 00 00 00       	mov    $0x0,%eax
80103cce:	eb 2f                	jmp    80103cff <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103cd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cd3:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103cd7:	0f b7 c0             	movzwl %ax,%eax
80103cda:	83 ec 08             	sub    $0x8,%esp
80103cdd:	50                   	push   %eax
80103cde:	ff 75 f0             	push   -0x10(%ebp)
80103ce1:	e8 10 fe ff ff       	call   80103af6 <sum>
80103ce6:	83 c4 10             	add    $0x10,%esp
80103ce9:	84 c0                	test   %al,%al
80103ceb:	74 07                	je     80103cf4 <mpconfig+0x9e>
    return 0;
80103ced:	b8 00 00 00 00       	mov    $0x0,%eax
80103cf2:	eb 0b                	jmp    80103cff <mpconfig+0xa9>
  *pmp = mp;
80103cf4:	8b 45 08             	mov    0x8(%ebp),%eax
80103cf7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103cfa:	89 10                	mov    %edx,(%eax)
  return conf;
80103cfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103cff:	c9                   	leave
80103d00:	c3                   	ret

80103d01 <mpinit>:

void
mpinit(void)
{
80103d01:	55                   	push   %ebp
80103d02:	89 e5                	mov    %esp,%ebp
80103d04:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103d07:	c7 05 0c 19 11 80 20 	movl   $0x80111320,0x8011190c
80103d0e:	13 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103d11:	83 ec 0c             	sub    $0xc,%esp
80103d14:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103d17:	50                   	push   %eax
80103d18:	e8 39 ff ff ff       	call   80103c56 <mpconfig>
80103d1d:	83 c4 10             	add    $0x10,%esp
80103d20:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d23:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d27:	0f 84 ba 01 00 00    	je     80103ee7 <mpinit+0x1e6>
    return;
  ismp = 1;
80103d2d:	c7 05 00 19 11 80 01 	movl   $0x1,0x80111900
80103d34:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103d37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d3a:	8b 40 24             	mov    0x24(%eax),%eax
80103d3d:	a3 20 12 11 80       	mov    %eax,0x80111220
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d45:	83 c0 2c             	add    $0x2c,%eax
80103d48:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d4e:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d52:	0f b7 d0             	movzwl %ax,%edx
80103d55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d58:	01 d0                	add    %edx,%eax
80103d5a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d5d:	e9 16 01 00 00       	jmp    80103e78 <mpinit+0x177>
    switch(*p){
80103d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d65:	0f b6 00             	movzbl (%eax),%eax
80103d68:	0f b6 c0             	movzbl %al,%eax
80103d6b:	83 f8 04             	cmp    $0x4,%eax
80103d6e:	0f 8f e0 00 00 00    	jg     80103e54 <mpinit+0x153>
80103d74:	83 f8 03             	cmp    $0x3,%eax
80103d77:	0f 8d d1 00 00 00    	jge    80103e4e <mpinit+0x14d>
80103d7d:	83 f8 02             	cmp    $0x2,%eax
80103d80:	0f 84 b0 00 00 00    	je     80103e36 <mpinit+0x135>
80103d86:	83 f8 02             	cmp    $0x2,%eax
80103d89:	0f 8f c5 00 00 00    	jg     80103e54 <mpinit+0x153>
80103d8f:	85 c0                	test   %eax,%eax
80103d91:	74 0e                	je     80103da1 <mpinit+0xa0>
80103d93:	83 f8 01             	cmp    $0x1,%eax
80103d96:	0f 84 b2 00 00 00    	je     80103e4e <mpinit+0x14d>
80103d9c:	e9 b3 00 00 00       	jmp    80103e54 <mpinit+0x153>
    case MPPROC:
      proc = (struct mpproc*)p;
80103da1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu != proc->apicid){
80103da7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103daa:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103dae:	0f b6 d0             	movzbl %al,%edx
80103db1:	a1 04 19 11 80       	mov    0x80111904,%eax
80103db6:	39 c2                	cmp    %eax,%edx
80103db8:	74 2b                	je     80103de5 <mpinit+0xe4>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103dba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103dbd:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103dc1:	0f b6 d0             	movzbl %al,%edx
80103dc4:	a1 04 19 11 80       	mov    0x80111904,%eax
80103dc9:	83 ec 04             	sub    $0x4,%esp
80103dcc:	52                   	push   %edx
80103dcd:	50                   	push   %eax
80103dce:	68 5e 88 10 80       	push   $0x8010885e
80103dd3:	e8 ec c5 ff ff       	call   801003c4 <cprintf>
80103dd8:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103ddb:	c7 05 00 19 11 80 00 	movl   $0x0,0x80111900
80103de2:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103de5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103de8:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103dec:	0f b6 c0             	movzbl %al,%eax
80103def:	83 e0 02             	and    $0x2,%eax
80103df2:	85 c0                	test   %eax,%eax
80103df4:	74 15                	je     80103e0b <mpinit+0x10a>
        bcpu = &cpus[ncpu];
80103df6:	a1 04 19 11 80       	mov    0x80111904,%eax
80103dfb:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e01:	05 20 13 11 80       	add    $0x80111320,%eax
80103e06:	a3 0c 19 11 80       	mov    %eax,0x8011190c
      cpus[ncpu].id = ncpu;
80103e0b:	8b 15 04 19 11 80    	mov    0x80111904,%edx
80103e11:	a1 04 19 11 80       	mov    0x80111904,%eax
80103e16:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e1c:	05 20 13 11 80       	add    $0x80111320,%eax
80103e21:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103e23:	a1 04 19 11 80       	mov    0x80111904,%eax
80103e28:	83 c0 01             	add    $0x1,%eax
80103e2b:	a3 04 19 11 80       	mov    %eax,0x80111904
      p += sizeof(struct mpproc);
80103e30:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103e34:	eb 42                	jmp    80103e78 <mpinit+0x177>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e39:	89 45 e8             	mov    %eax,-0x18(%ebp)
      ioapicid = ioapic->apicno;
80103e3c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e3f:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e43:	a2 08 19 11 80       	mov    %al,0x80111908
      p += sizeof(struct mpioapic);
80103e48:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e4c:	eb 2a                	jmp    80103e78 <mpinit+0x177>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103e4e:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e52:	eb 24                	jmp    80103e78 <mpinit+0x177>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e57:	0f b6 00             	movzbl (%eax),%eax
80103e5a:	0f b6 c0             	movzbl %al,%eax
80103e5d:	83 ec 08             	sub    $0x8,%esp
80103e60:	50                   	push   %eax
80103e61:	68 7c 88 10 80       	push   $0x8010887c
80103e66:	e8 59 c5 ff ff       	call   801003c4 <cprintf>
80103e6b:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103e6e:	c7 05 00 19 11 80 00 	movl   $0x0,0x80111900
80103e75:	00 00 00 
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e7b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103e7e:	0f 82 de fe ff ff    	jb     80103d62 <mpinit+0x61>
    }
  }
  if(!ismp){
80103e84:	a1 00 19 11 80       	mov    0x80111900,%eax
80103e89:	85 c0                	test   %eax,%eax
80103e8b:	75 1d                	jne    80103eaa <mpinit+0x1a9>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103e8d:	c7 05 04 19 11 80 01 	movl   $0x1,0x80111904
80103e94:	00 00 00 
    lapic = 0;
80103e97:	c7 05 20 12 11 80 00 	movl   $0x0,0x80111220
80103e9e:	00 00 00 
    ioapicid = 0;
80103ea1:	c6 05 08 19 11 80 00 	movb   $0x0,0x80111908
    return;
80103ea8:	eb 3e                	jmp    80103ee8 <mpinit+0x1e7>
  }

  if(mp->imcrp){
80103eaa:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ead:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103eb1:	84 c0                	test   %al,%al
80103eb3:	74 33                	je     80103ee8 <mpinit+0x1e7>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103eb5:	83 ec 08             	sub    $0x8,%esp
80103eb8:	6a 70                	push   $0x70
80103eba:	6a 22                	push   $0x22
80103ebc:	e8 fe fb ff ff       	call   80103abf <outb>
80103ec1:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103ec4:	83 ec 0c             	sub    $0xc,%esp
80103ec7:	6a 23                	push   $0x23
80103ec9:	e8 d4 fb ff ff       	call   80103aa2 <inb>
80103ece:	83 c4 10             	add    $0x10,%esp
80103ed1:	83 c8 01             	or     $0x1,%eax
80103ed4:	0f b6 c0             	movzbl %al,%eax
80103ed7:	83 ec 08             	sub    $0x8,%esp
80103eda:	50                   	push   %eax
80103edb:	6a 23                	push   $0x23
80103edd:	e8 dd fb ff ff       	call   80103abf <outb>
80103ee2:	83 c4 10             	add    $0x10,%esp
80103ee5:	eb 01                	jmp    80103ee8 <mpinit+0x1e7>
    return;
80103ee7:	90                   	nop
  }
}
80103ee8:	c9                   	leave
80103ee9:	c3                   	ret

80103eea <outb>:
{
80103eea:	55                   	push   %ebp
80103eeb:	89 e5                	mov    %esp,%ebp
80103eed:	83 ec 08             	sub    $0x8,%esp
80103ef0:	8b 55 08             	mov    0x8(%ebp),%edx
80103ef3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ef6:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103efa:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103efd:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103f01:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103f05:	ee                   	out    %al,(%dx)
}
80103f06:	90                   	nop
80103f07:	c9                   	leave
80103f08:	c3                   	ret

80103f09 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103f09:	55                   	push   %ebp
80103f0a:	89 e5                	mov    %esp,%ebp
80103f0c:	83 ec 04             	sub    $0x4,%esp
80103f0f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f12:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103f16:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f1a:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103f20:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f24:	0f b6 c0             	movzbl %al,%eax
80103f27:	50                   	push   %eax
80103f28:	6a 21                	push   $0x21
80103f2a:	e8 bb ff ff ff       	call   80103eea <outb>
80103f2f:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103f32:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f36:	66 c1 e8 08          	shr    $0x8,%ax
80103f3a:	0f b6 c0             	movzbl %al,%eax
80103f3d:	50                   	push   %eax
80103f3e:	68 a1 00 00 00       	push   $0xa1
80103f43:	e8 a2 ff ff ff       	call   80103eea <outb>
80103f48:	83 c4 08             	add    $0x8,%esp
}
80103f4b:	90                   	nop
80103f4c:	c9                   	leave
80103f4d:	c3                   	ret

80103f4e <picenable>:

void
picenable(int irq)
{
80103f4e:	55                   	push   %ebp
80103f4f:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103f51:	8b 45 08             	mov    0x8(%ebp),%eax
80103f54:	ba 01 00 00 00       	mov    $0x1,%edx
80103f59:	89 c1                	mov    %eax,%ecx
80103f5b:	d3 e2                	shl    %cl,%edx
80103f5d:	89 d0                	mov    %edx,%eax
80103f5f:	f7 d0                	not    %eax
80103f61:	89 c2                	mov    %eax,%edx
80103f63:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f6a:	21 d0                	and    %edx,%eax
80103f6c:	0f b7 c0             	movzwl %ax,%eax
80103f6f:	50                   	push   %eax
80103f70:	e8 94 ff ff ff       	call   80103f09 <picsetmask>
80103f75:	83 c4 04             	add    $0x4,%esp
}
80103f78:	90                   	nop
80103f79:	c9                   	leave
80103f7a:	c3                   	ret

80103f7b <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103f7b:	55                   	push   %ebp
80103f7c:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103f7e:	68 ff 00 00 00       	push   $0xff
80103f83:	6a 21                	push   $0x21
80103f85:	e8 60 ff ff ff       	call   80103eea <outb>
80103f8a:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103f8d:	68 ff 00 00 00       	push   $0xff
80103f92:	68 a1 00 00 00       	push   $0xa1
80103f97:	e8 4e ff ff ff       	call   80103eea <outb>
80103f9c:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103f9f:	6a 11                	push   $0x11
80103fa1:	6a 20                	push   $0x20
80103fa3:	e8 42 ff ff ff       	call   80103eea <outb>
80103fa8:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103fab:	6a 20                	push   $0x20
80103fad:	6a 21                	push   $0x21
80103faf:	e8 36 ff ff ff       	call   80103eea <outb>
80103fb4:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103fb7:	6a 04                	push   $0x4
80103fb9:	6a 21                	push   $0x21
80103fbb:	e8 2a ff ff ff       	call   80103eea <outb>
80103fc0:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103fc3:	6a 03                	push   $0x3
80103fc5:	6a 21                	push   $0x21
80103fc7:	e8 1e ff ff ff       	call   80103eea <outb>
80103fcc:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103fcf:	6a 11                	push   $0x11
80103fd1:	68 a0 00 00 00       	push   $0xa0
80103fd6:	e8 0f ff ff ff       	call   80103eea <outb>
80103fdb:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103fde:	6a 28                	push   $0x28
80103fe0:	68 a1 00 00 00       	push   $0xa1
80103fe5:	e8 00 ff ff ff       	call   80103eea <outb>
80103fea:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103fed:	6a 02                	push   $0x2
80103fef:	68 a1 00 00 00       	push   $0xa1
80103ff4:	e8 f1 fe ff ff       	call   80103eea <outb>
80103ff9:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103ffc:	6a 03                	push   $0x3
80103ffe:	68 a1 00 00 00       	push   $0xa1
80104003:	e8 e2 fe ff ff       	call   80103eea <outb>
80104008:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
8010400b:	6a 68                	push   $0x68
8010400d:	6a 20                	push   $0x20
8010400f:	e8 d6 fe ff ff       	call   80103eea <outb>
80104014:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80104017:	6a 0a                	push   $0xa
80104019:	6a 20                	push   $0x20
8010401b:	e8 ca fe ff ff       	call   80103eea <outb>
80104020:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80104023:	6a 68                	push   $0x68
80104025:	68 a0 00 00 00       	push   $0xa0
8010402a:	e8 bb fe ff ff       	call   80103eea <outb>
8010402f:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80104032:	6a 0a                	push   $0xa
80104034:	68 a0 00 00 00       	push   $0xa0
80104039:	e8 ac fe ff ff       	call   80103eea <outb>
8010403e:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80104041:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80104048:	66 83 f8 ff          	cmp    $0xffff,%ax
8010404c:	74 13                	je     80104061 <picinit+0xe6>
    picsetmask(irqmask);
8010404e:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80104055:	0f b7 c0             	movzwl %ax,%eax
80104058:	50                   	push   %eax
80104059:	e8 ab fe ff ff       	call   80103f09 <picsetmask>
8010405e:	83 c4 04             	add    $0x4,%esp
}
80104061:	90                   	nop
80104062:	c9                   	leave
80104063:	c3                   	ret

80104064 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104064:	55                   	push   %ebp
80104065:	89 e5                	mov    %esp,%ebp
80104067:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
8010406a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104071:	8b 45 0c             	mov    0xc(%ebp),%eax
80104074:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010407a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010407d:	8b 10                	mov    (%eax),%edx
8010407f:	8b 45 08             	mov    0x8(%ebp),%eax
80104082:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104084:	e8 3b cf ff ff       	call   80100fc4 <filealloc>
80104089:	8b 55 08             	mov    0x8(%ebp),%edx
8010408c:	89 02                	mov    %eax,(%edx)
8010408e:	8b 45 08             	mov    0x8(%ebp),%eax
80104091:	8b 00                	mov    (%eax),%eax
80104093:	85 c0                	test   %eax,%eax
80104095:	0f 84 c8 00 00 00    	je     80104163 <pipealloc+0xff>
8010409b:	e8 24 cf ff ff       	call   80100fc4 <filealloc>
801040a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801040a3:	89 02                	mov    %eax,(%edx)
801040a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801040a8:	8b 00                	mov    (%eax),%eax
801040aa:	85 c0                	test   %eax,%eax
801040ac:	0f 84 b1 00 00 00    	je     80104163 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801040b2:	e8 c2 eb ff ff       	call   80102c79 <kalloc>
801040b7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801040ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040be:	0f 84 a2 00 00 00    	je     80104166 <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801040c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c7:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801040ce:	00 00 00 
  p->writeopen = 1;
801040d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040d4:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801040db:	00 00 00 
  p->nwrite = 0;
801040de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040e1:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801040e8:	00 00 00 
  p->nread = 0;
801040eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040ee:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801040f5:	00 00 00 
  initlock(&p->lock, "pipe");
801040f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040fb:	83 ec 08             	sub    $0x8,%esp
801040fe:	68 9c 88 10 80       	push   $0x8010889c
80104103:	50                   	push   %eax
80104104:	e8 1a 0f 00 00       	call   80105023 <initlock>
80104109:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
8010410c:	8b 45 08             	mov    0x8(%ebp),%eax
8010410f:	8b 00                	mov    (%eax),%eax
80104111:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104117:	8b 45 08             	mov    0x8(%ebp),%eax
8010411a:	8b 00                	mov    (%eax),%eax
8010411c:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104120:	8b 45 08             	mov    0x8(%ebp),%eax
80104123:	8b 00                	mov    (%eax),%eax
80104125:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104129:	8b 45 08             	mov    0x8(%ebp),%eax
8010412c:	8b 00                	mov    (%eax),%eax
8010412e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104131:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104134:	8b 45 0c             	mov    0xc(%ebp),%eax
80104137:	8b 00                	mov    (%eax),%eax
80104139:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010413f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104142:	8b 00                	mov    (%eax),%eax
80104144:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104148:	8b 45 0c             	mov    0xc(%ebp),%eax
8010414b:	8b 00                	mov    (%eax),%eax
8010414d:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104151:	8b 45 0c             	mov    0xc(%ebp),%eax
80104154:	8b 00                	mov    (%eax),%eax
80104156:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104159:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
8010415c:	b8 00 00 00 00       	mov    $0x0,%eax
80104161:	eb 51                	jmp    801041b4 <pipealloc+0x150>
    goto bad;
80104163:	90                   	nop
80104164:	eb 01                	jmp    80104167 <pipealloc+0x103>
    goto bad;
80104166:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80104167:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010416b:	74 0e                	je     8010417b <pipealloc+0x117>
    kfree((char*)p);
8010416d:	83 ec 0c             	sub    $0xc,%esp
80104170:	ff 75 f4             	push   -0xc(%ebp)
80104173:	e8 64 ea ff ff       	call   80102bdc <kfree>
80104178:	83 c4 10             	add    $0x10,%esp
  if(*f0)
8010417b:	8b 45 08             	mov    0x8(%ebp),%eax
8010417e:	8b 00                	mov    (%eax),%eax
80104180:	85 c0                	test   %eax,%eax
80104182:	74 11                	je     80104195 <pipealloc+0x131>
    fileclose(*f0);
80104184:	8b 45 08             	mov    0x8(%ebp),%eax
80104187:	8b 00                	mov    (%eax),%eax
80104189:	83 ec 0c             	sub    $0xc,%esp
8010418c:	50                   	push   %eax
8010418d:	e8 f0 ce ff ff       	call   80101082 <fileclose>
80104192:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104195:	8b 45 0c             	mov    0xc(%ebp),%eax
80104198:	8b 00                	mov    (%eax),%eax
8010419a:	85 c0                	test   %eax,%eax
8010419c:	74 11                	je     801041af <pipealloc+0x14b>
    fileclose(*f1);
8010419e:	8b 45 0c             	mov    0xc(%ebp),%eax
801041a1:	8b 00                	mov    (%eax),%eax
801041a3:	83 ec 0c             	sub    $0xc,%esp
801041a6:	50                   	push   %eax
801041a7:	e8 d6 ce ff ff       	call   80101082 <fileclose>
801041ac:	83 c4 10             	add    $0x10,%esp
  return -1;
801041af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801041b4:	c9                   	leave
801041b5:	c3                   	ret

801041b6 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801041b6:	55                   	push   %ebp
801041b7:	89 e5                	mov    %esp,%ebp
801041b9:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801041bc:	8b 45 08             	mov    0x8(%ebp),%eax
801041bf:	83 ec 0c             	sub    $0xc,%esp
801041c2:	50                   	push   %eax
801041c3:	e8 7d 0e 00 00       	call   80105045 <acquire>
801041c8:	83 c4 10             	add    $0x10,%esp
  if(writable){
801041cb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801041cf:	74 23                	je     801041f4 <pipeclose+0x3e>
    p->writeopen = 0;
801041d1:	8b 45 08             	mov    0x8(%ebp),%eax
801041d4:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801041db:	00 00 00 
    wakeup(&p->nread);
801041de:	8b 45 08             	mov    0x8(%ebp),%eax
801041e1:	05 34 02 00 00       	add    $0x234,%eax
801041e6:	83 ec 0c             	sub    $0xc,%esp
801041e9:	50                   	push   %eax
801041ea:	e8 47 0c 00 00       	call   80104e36 <wakeup>
801041ef:	83 c4 10             	add    $0x10,%esp
801041f2:	eb 21                	jmp    80104215 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801041f4:	8b 45 08             	mov    0x8(%ebp),%eax
801041f7:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801041fe:	00 00 00 
    wakeup(&p->nwrite);
80104201:	8b 45 08             	mov    0x8(%ebp),%eax
80104204:	05 38 02 00 00       	add    $0x238,%eax
80104209:	83 ec 0c             	sub    $0xc,%esp
8010420c:	50                   	push   %eax
8010420d:	e8 24 0c 00 00       	call   80104e36 <wakeup>
80104212:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104215:	8b 45 08             	mov    0x8(%ebp),%eax
80104218:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010421e:	85 c0                	test   %eax,%eax
80104220:	75 2c                	jne    8010424e <pipeclose+0x98>
80104222:	8b 45 08             	mov    0x8(%ebp),%eax
80104225:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010422b:	85 c0                	test   %eax,%eax
8010422d:	75 1f                	jne    8010424e <pipeclose+0x98>
    release(&p->lock);
8010422f:	8b 45 08             	mov    0x8(%ebp),%eax
80104232:	83 ec 0c             	sub    $0xc,%esp
80104235:	50                   	push   %eax
80104236:	e8 71 0e 00 00       	call   801050ac <release>
8010423b:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
8010423e:	83 ec 0c             	sub    $0xc,%esp
80104241:	ff 75 08             	push   0x8(%ebp)
80104244:	e8 93 e9 ff ff       	call   80102bdc <kfree>
80104249:	83 c4 10             	add    $0x10,%esp
8010424c:	eb 10                	jmp    8010425e <pipeclose+0xa8>
  } else
    release(&p->lock);
8010424e:	8b 45 08             	mov    0x8(%ebp),%eax
80104251:	83 ec 0c             	sub    $0xc,%esp
80104254:	50                   	push   %eax
80104255:	e8 52 0e 00 00       	call   801050ac <release>
8010425a:	83 c4 10             	add    $0x10,%esp
}
8010425d:	90                   	nop
8010425e:	90                   	nop
8010425f:	c9                   	leave
80104260:	c3                   	ret

80104261 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104261:	55                   	push   %ebp
80104262:	89 e5                	mov    %esp,%ebp
80104264:	53                   	push   %ebx
80104265:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104268:	8b 45 08             	mov    0x8(%ebp),%eax
8010426b:	83 ec 0c             	sub    $0xc,%esp
8010426e:	50                   	push   %eax
8010426f:	e8 d1 0d 00 00       	call   80105045 <acquire>
80104274:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104277:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010427e:	e9 ae 00 00 00       	jmp    80104331 <pipewrite+0xd0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104283:	8b 45 08             	mov    0x8(%ebp),%eax
80104286:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010428c:	85 c0                	test   %eax,%eax
8010428e:	74 0d                	je     8010429d <pipewrite+0x3c>
80104290:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104296:	8b 40 24             	mov    0x24(%eax),%eax
80104299:	85 c0                	test   %eax,%eax
8010429b:	74 19                	je     801042b6 <pipewrite+0x55>
        release(&p->lock);
8010429d:	8b 45 08             	mov    0x8(%ebp),%eax
801042a0:	83 ec 0c             	sub    $0xc,%esp
801042a3:	50                   	push   %eax
801042a4:	e8 03 0e 00 00       	call   801050ac <release>
801042a9:	83 c4 10             	add    $0x10,%esp
        return -1;
801042ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042b1:	e9 a9 00 00 00       	jmp    8010435f <pipewrite+0xfe>
      }
      wakeup(&p->nread);
801042b6:	8b 45 08             	mov    0x8(%ebp),%eax
801042b9:	05 34 02 00 00       	add    $0x234,%eax
801042be:	83 ec 0c             	sub    $0xc,%esp
801042c1:	50                   	push   %eax
801042c2:	e8 6f 0b 00 00       	call   80104e36 <wakeup>
801042c7:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801042ca:	8b 45 08             	mov    0x8(%ebp),%eax
801042cd:	8b 55 08             	mov    0x8(%ebp),%edx
801042d0:	81 c2 38 02 00 00    	add    $0x238,%edx
801042d6:	83 ec 08             	sub    $0x8,%esp
801042d9:	50                   	push   %eax
801042da:	52                   	push   %edx
801042db:	e8 6a 0a 00 00       	call   80104d4a <sleep>
801042e0:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801042e3:	8b 45 08             	mov    0x8(%ebp),%eax
801042e6:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801042ec:	8b 45 08             	mov    0x8(%ebp),%eax
801042ef:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042f5:	05 00 02 00 00       	add    $0x200,%eax
801042fa:	39 c2                	cmp    %eax,%edx
801042fc:	74 85                	je     80104283 <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801042fe:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104301:	8b 45 0c             	mov    0xc(%ebp),%eax
80104304:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104307:	8b 45 08             	mov    0x8(%ebp),%eax
8010430a:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104310:	8d 48 01             	lea    0x1(%eax),%ecx
80104313:	8b 55 08             	mov    0x8(%ebp),%edx
80104316:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010431c:	25 ff 01 00 00       	and    $0x1ff,%eax
80104321:	89 c1                	mov    %eax,%ecx
80104323:	0f b6 13             	movzbl (%ebx),%edx
80104326:	8b 45 08             	mov    0x8(%ebp),%eax
80104329:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
8010432d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104331:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104334:	3b 45 10             	cmp    0x10(%ebp),%eax
80104337:	7c aa                	jl     801042e3 <pipewrite+0x82>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104339:	8b 45 08             	mov    0x8(%ebp),%eax
8010433c:	05 34 02 00 00       	add    $0x234,%eax
80104341:	83 ec 0c             	sub    $0xc,%esp
80104344:	50                   	push   %eax
80104345:	e8 ec 0a 00 00       	call   80104e36 <wakeup>
8010434a:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010434d:	8b 45 08             	mov    0x8(%ebp),%eax
80104350:	83 ec 0c             	sub    $0xc,%esp
80104353:	50                   	push   %eax
80104354:	e8 53 0d 00 00       	call   801050ac <release>
80104359:	83 c4 10             	add    $0x10,%esp
  return n;
8010435c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010435f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104362:	c9                   	leave
80104363:	c3                   	ret

80104364 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104364:	55                   	push   %ebp
80104365:	89 e5                	mov    %esp,%ebp
80104367:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
8010436a:	8b 45 08             	mov    0x8(%ebp),%eax
8010436d:	83 ec 0c             	sub    $0xc,%esp
80104370:	50                   	push   %eax
80104371:	e8 cf 0c 00 00       	call   80105045 <acquire>
80104376:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104379:	eb 3f                	jmp    801043ba <piperead+0x56>
    if(proc->killed){
8010437b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104381:	8b 40 24             	mov    0x24(%eax),%eax
80104384:	85 c0                	test   %eax,%eax
80104386:	74 19                	je     801043a1 <piperead+0x3d>
      release(&p->lock);
80104388:	8b 45 08             	mov    0x8(%ebp),%eax
8010438b:	83 ec 0c             	sub    $0xc,%esp
8010438e:	50                   	push   %eax
8010438f:	e8 18 0d 00 00       	call   801050ac <release>
80104394:	83 c4 10             	add    $0x10,%esp
      return -1;
80104397:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010439c:	e9 be 00 00 00       	jmp    8010445f <piperead+0xfb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801043a1:	8b 45 08             	mov    0x8(%ebp),%eax
801043a4:	8b 55 08             	mov    0x8(%ebp),%edx
801043a7:	81 c2 34 02 00 00    	add    $0x234,%edx
801043ad:	83 ec 08             	sub    $0x8,%esp
801043b0:	50                   	push   %eax
801043b1:	52                   	push   %edx
801043b2:	e8 93 09 00 00       	call   80104d4a <sleep>
801043b7:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801043ba:	8b 45 08             	mov    0x8(%ebp),%eax
801043bd:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043c3:	8b 45 08             	mov    0x8(%ebp),%eax
801043c6:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043cc:	39 c2                	cmp    %eax,%edx
801043ce:	75 0d                	jne    801043dd <piperead+0x79>
801043d0:	8b 45 08             	mov    0x8(%ebp),%eax
801043d3:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801043d9:	85 c0                	test   %eax,%eax
801043db:	75 9e                	jne    8010437b <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801043e4:	eb 48                	jmp    8010442e <piperead+0xca>
    if(p->nread == p->nwrite)
801043e6:	8b 45 08             	mov    0x8(%ebp),%eax
801043e9:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043ef:	8b 45 08             	mov    0x8(%ebp),%eax
801043f2:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043f8:	39 c2                	cmp    %eax,%edx
801043fa:	74 3c                	je     80104438 <piperead+0xd4>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801043fc:	8b 45 08             	mov    0x8(%ebp),%eax
801043ff:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104405:	8d 48 01             	lea    0x1(%eax),%ecx
80104408:	8b 55 08             	mov    0x8(%ebp),%edx
8010440b:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104411:	25 ff 01 00 00       	and    $0x1ff,%eax
80104416:	89 c1                	mov    %eax,%ecx
80104418:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010441b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010441e:	01 c2                	add    %eax,%edx
80104420:	8b 45 08             	mov    0x8(%ebp),%eax
80104423:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
80104428:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010442a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010442e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104431:	3b 45 10             	cmp    0x10(%ebp),%eax
80104434:	7c b0                	jl     801043e6 <piperead+0x82>
80104436:	eb 01                	jmp    80104439 <piperead+0xd5>
      break;
80104438:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104439:	8b 45 08             	mov    0x8(%ebp),%eax
8010443c:	05 38 02 00 00       	add    $0x238,%eax
80104441:	83 ec 0c             	sub    $0xc,%esp
80104444:	50                   	push   %eax
80104445:	e8 ec 09 00 00       	call   80104e36 <wakeup>
8010444a:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010444d:	8b 45 08             	mov    0x8(%ebp),%eax
80104450:	83 ec 0c             	sub    $0xc,%esp
80104453:	50                   	push   %eax
80104454:	e8 53 0c 00 00       	call   801050ac <release>
80104459:	83 c4 10             	add    $0x10,%esp
  return i;
8010445c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010445f:	c9                   	leave
80104460:	c3                   	ret

80104461 <readeflags>:
{
80104461:	55                   	push   %ebp
80104462:	89 e5                	mov    %esp,%ebp
80104464:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104467:	9c                   	pushf
80104468:	58                   	pop    %eax
80104469:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010446c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010446f:	c9                   	leave
80104470:	c3                   	ret

80104471 <sti>:
{
80104471:	55                   	push   %ebp
80104472:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104474:	fb                   	sti
}
80104475:	90                   	nop
80104476:	5d                   	pop    %ebp
80104477:	c3                   	ret

80104478 <halt>:
}

// CS550: to solve the 100%-CPU-utilization-when-idling problem - "hlt" instruction puts CPU to sleep
static inline void
halt()
{
80104478:	55                   	push   %ebp
80104479:	89 e5                	mov    %esp,%ebp
    asm volatile("hlt" : : :"memory");
8010447b:	f4                   	hlt
}
8010447c:	90                   	nop
8010447d:	5d                   	pop    %ebp
8010447e:	c3                   	ret

8010447f <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010447f:	55                   	push   %ebp
80104480:	89 e5                	mov    %esp,%ebp
80104482:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104485:	83 ec 08             	sub    $0x8,%esp
80104488:	68 a1 88 10 80       	push   $0x801088a1
8010448d:	68 20 19 11 80       	push   $0x80111920
80104492:	e8 8c 0b 00 00       	call   80105023 <initlock>
80104497:	83 c4 10             	add    $0x10,%esp
}
8010449a:	90                   	nop
8010449b:	c9                   	leave
8010449c:	c3                   	ret

8010449d <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
8010449d:	55                   	push   %ebp
8010449e:	89 e5                	mov    %esp,%ebp
801044a0:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801044a3:	83 ec 0c             	sub    $0xc,%esp
801044a6:	68 20 19 11 80       	push   $0x80111920
801044ab:	e8 95 0b 00 00       	call   80105045 <acquire>
801044b0:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044b3:	c7 45 f4 54 19 11 80 	movl   $0x80111954,-0xc(%ebp)
801044ba:	eb 0e                	jmp    801044ca <allocproc+0x2d>
    if(p->state == UNUSED)
801044bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044bf:	8b 40 0c             	mov    0xc(%eax),%eax
801044c2:	85 c0                	test   %eax,%eax
801044c4:	74 27                	je     801044ed <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044c6:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801044ca:	81 7d f4 54 38 11 80 	cmpl   $0x80113854,-0xc(%ebp)
801044d1:	72 e9                	jb     801044bc <allocproc+0x1f>
      goto found;
  release(&ptable.lock);
801044d3:	83 ec 0c             	sub    $0xc,%esp
801044d6:	68 20 19 11 80       	push   $0x80111920
801044db:	e8 cc 0b 00 00       	call   801050ac <release>
801044e0:	83 c4 10             	add    $0x10,%esp
  return 0;
801044e3:	b8 00 00 00 00       	mov    $0x0,%eax
801044e8:	e9 b2 00 00 00       	jmp    8010459f <allocproc+0x102>
      goto found;
801044ed:	90                   	nop

found:
  p->state = EMBRYO;
801044ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f1:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801044f8:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801044fd:	8d 50 01             	lea    0x1(%eax),%edx
80104500:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
80104506:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104509:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
8010450c:	83 ec 0c             	sub    $0xc,%esp
8010450f:	68 20 19 11 80       	push   $0x80111920
80104514:	e8 93 0b 00 00       	call   801050ac <release>
80104519:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010451c:	e8 58 e7 ff ff       	call   80102c79 <kalloc>
80104521:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104524:	89 42 08             	mov    %eax,0x8(%edx)
80104527:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010452a:	8b 40 08             	mov    0x8(%eax),%eax
8010452d:	85 c0                	test   %eax,%eax
8010452f:	75 11                	jne    80104542 <allocproc+0xa5>
    p->state = UNUSED;
80104531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104534:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010453b:	b8 00 00 00 00       	mov    $0x0,%eax
80104540:	eb 5d                	jmp    8010459f <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
80104542:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104545:	8b 40 08             	mov    0x8(%eax),%eax
80104548:	05 00 10 00 00       	add    $0x1000,%eax
8010454d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104550:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104557:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010455a:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010455d:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104561:	ba 84 66 10 80       	mov    $0x80106684,%edx
80104566:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104569:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010456b:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
8010456f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104572:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104575:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104578:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010457b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010457e:	83 ec 04             	sub    $0x4,%esp
80104581:	6a 14                	push   $0x14
80104583:	6a 00                	push   $0x0
80104585:	50                   	push   %eax
80104586:	e8 1e 0d 00 00       	call   801052a9 <memset>
8010458b:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
8010458e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104591:	8b 40 1c             	mov    0x1c(%eax),%eax
80104594:	ba 04 4d 10 80       	mov    $0x80104d04,%edx
80104599:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
8010459c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010459f:	c9                   	leave
801045a0:	c3                   	ret

801045a1 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801045a1:	55                   	push   %ebp
801045a2:	89 e5                	mov    %esp,%ebp
801045a4:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801045a7:	e8 f1 fe ff ff       	call   8010449d <allocproc>
801045ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801045af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b2:	a3 54 38 11 80       	mov    %eax,0x80113854
  if((p->pgdir = setupkvm()) == 0)
801045b7:	e8 8e 37 00 00       	call   80107d4a <setupkvm>
801045bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045bf:	89 42 04             	mov    %eax,0x4(%edx)
801045c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c5:	8b 40 04             	mov    0x4(%eax),%eax
801045c8:	85 c0                	test   %eax,%eax
801045ca:	75 0d                	jne    801045d9 <userinit+0x38>
    panic("userinit: out of memory?");
801045cc:	83 ec 0c             	sub    $0xc,%esp
801045cf:	68 a8 88 10 80       	push   $0x801088a8
801045d4:	e8 a0 bf ff ff       	call   80100579 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801045d9:	ba 2c 00 00 00       	mov    $0x2c,%edx
801045de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e1:	8b 40 04             	mov    0x4(%eax),%eax
801045e4:	83 ec 04             	sub    $0x4,%esp
801045e7:	52                   	push   %edx
801045e8:	68 e0 b4 10 80       	push   $0x8010b4e0
801045ed:	50                   	push   %eax
801045ee:	e8 b2 39 00 00       	call   80107fa5 <inituvm>
801045f3:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
801045f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f9:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801045ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104602:	8b 40 18             	mov    0x18(%eax),%eax
80104605:	83 ec 04             	sub    $0x4,%esp
80104608:	6a 4c                	push   $0x4c
8010460a:	6a 00                	push   $0x0
8010460c:	50                   	push   %eax
8010460d:	e8 97 0c 00 00       	call   801052a9 <memset>
80104612:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104615:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104618:	8b 40 18             	mov    0x18(%eax),%eax
8010461b:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104621:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104624:	8b 40 18             	mov    0x18(%eax),%eax
80104627:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010462d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104630:	8b 50 18             	mov    0x18(%eax),%edx
80104633:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104636:	8b 40 18             	mov    0x18(%eax),%eax
80104639:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010463d:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104641:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104644:	8b 50 18             	mov    0x18(%eax),%edx
80104647:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010464a:	8b 40 18             	mov    0x18(%eax),%eax
8010464d:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104651:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104655:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104658:	8b 40 18             	mov    0x18(%eax),%eax
8010465b:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104662:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104665:	8b 40 18             	mov    0x18(%eax),%eax
80104668:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010466f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104672:	8b 40 18             	mov    0x18(%eax),%eax
80104675:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010467c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010467f:	83 c0 6c             	add    $0x6c,%eax
80104682:	83 ec 04             	sub    $0x4,%esp
80104685:	6a 10                	push   $0x10
80104687:	68 c1 88 10 80       	push   $0x801088c1
8010468c:	50                   	push   %eax
8010468d:	e8 1a 0e 00 00       	call   801054ac <safestrcpy>
80104692:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80104695:	83 ec 0c             	sub    $0xc,%esp
80104698:	68 ca 88 10 80       	push   $0x801088ca
8010469d:	e8 98 de ff ff       	call   8010253a <namei>
801046a2:	83 c4 10             	add    $0x10,%esp
801046a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046a8:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
801046ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046ae:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801046b5:	90                   	nop
801046b6:	c9                   	leave
801046b7:	c3                   	ret

801046b8 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801046b8:	55                   	push   %ebp
801046b9:	89 e5                	mov    %esp,%ebp
801046bb:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
801046be:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046c4:	8b 00                	mov    (%eax),%eax
801046c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801046c9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801046cd:	7e 31                	jle    80104700 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801046cf:	8b 55 08             	mov    0x8(%ebp),%edx
801046d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d5:	01 c2                	add    %eax,%edx
801046d7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046dd:	8b 40 04             	mov    0x4(%eax),%eax
801046e0:	83 ec 04             	sub    $0x4,%esp
801046e3:	52                   	push   %edx
801046e4:	ff 75 f4             	push   -0xc(%ebp)
801046e7:	50                   	push   %eax
801046e8:	e8 05 3a 00 00       	call   801080f2 <allocuvm>
801046ed:	83 c4 10             	add    $0x10,%esp
801046f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801046f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801046f7:	75 3e                	jne    80104737 <growproc+0x7f>
      return -1;
801046f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046fe:	eb 59                	jmp    80104759 <growproc+0xa1>
  } else if(n < 0){
80104700:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104704:	79 31                	jns    80104737 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104706:	8b 55 08             	mov    0x8(%ebp),%edx
80104709:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010470c:	01 c2                	add    %eax,%edx
8010470e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104714:	8b 40 04             	mov    0x4(%eax),%eax
80104717:	83 ec 04             	sub    $0x4,%esp
8010471a:	52                   	push   %edx
8010471b:	ff 75 f4             	push   -0xc(%ebp)
8010471e:	50                   	push   %eax
8010471f:	e8 95 3a 00 00       	call   801081b9 <deallocuvm>
80104724:	83 c4 10             	add    $0x10,%esp
80104727:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010472a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010472e:	75 07                	jne    80104737 <growproc+0x7f>
      return -1;
80104730:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104735:	eb 22                	jmp    80104759 <growproc+0xa1>
  }
  proc->sz = sz;
80104737:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010473d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104740:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104742:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104748:	83 ec 0c             	sub    $0xc,%esp
8010474b:	50                   	push   %eax
8010474c:	e8 e0 36 00 00       	call   80107e31 <switchuvm>
80104751:	83 c4 10             	add    $0x10,%esp
  return 0;
80104754:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104759:	c9                   	leave
8010475a:	c3                   	ret

8010475b <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010475b:	55                   	push   %ebp
8010475c:	89 e5                	mov    %esp,%ebp
8010475e:	57                   	push   %edi
8010475f:	56                   	push   %esi
80104760:	53                   	push   %ebx
80104761:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
80104764:	e8 34 fd ff ff       	call   8010449d <allocproc>
80104769:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010476c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104770:	75 0a                	jne    8010477c <fork+0x21>
    return -1;
80104772:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104777:	e9 64 01 00 00       	jmp    801048e0 <fork+0x185>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
8010477c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104782:	8b 10                	mov    (%eax),%edx
80104784:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010478a:	8b 40 04             	mov    0x4(%eax),%eax
8010478d:	83 ec 08             	sub    $0x8,%esp
80104790:	52                   	push   %edx
80104791:	50                   	push   %eax
80104792:	e8 c0 3b 00 00       	call   80108357 <copyuvm>
80104797:	83 c4 10             	add    $0x10,%esp
8010479a:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010479d:	89 42 04             	mov    %eax,0x4(%edx)
801047a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047a3:	8b 40 04             	mov    0x4(%eax),%eax
801047a6:	85 c0                	test   %eax,%eax
801047a8:	75 30                	jne    801047da <fork+0x7f>
    kfree(np->kstack);
801047aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047ad:	8b 40 08             	mov    0x8(%eax),%eax
801047b0:	83 ec 0c             	sub    $0xc,%esp
801047b3:	50                   	push   %eax
801047b4:	e8 23 e4 ff ff       	call   80102bdc <kfree>
801047b9:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801047bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047bf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801047c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047c9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801047d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047d5:	e9 06 01 00 00       	jmp    801048e0 <fork+0x185>
  }
  np->sz = proc->sz;
801047da:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047e0:	8b 10                	mov    (%eax),%edx
801047e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047e5:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801047e7:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801047ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047f1:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801047f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047fa:	8b 48 18             	mov    0x18(%eax),%ecx
801047fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104800:	8b 40 18             	mov    0x18(%eax),%eax
80104803:	89 c2                	mov    %eax,%edx
80104805:	89 cb                	mov    %ecx,%ebx
80104807:	b8 13 00 00 00       	mov    $0x13,%eax
8010480c:	89 d7                	mov    %edx,%edi
8010480e:	89 de                	mov    %ebx,%esi
80104810:	89 c1                	mov    %eax,%ecx
80104812:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104814:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104817:	8b 40 18             	mov    0x18(%eax),%eax
8010481a:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104821:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104828:	eb 41                	jmp    8010486b <fork+0x110>
    if(proc->ofile[i])
8010482a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104830:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104833:	83 c2 08             	add    $0x8,%edx
80104836:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010483a:	85 c0                	test   %eax,%eax
8010483c:	74 29                	je     80104867 <fork+0x10c>
      np->ofile[i] = filedup(proc->ofile[i]);
8010483e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104844:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104847:	83 c2 08             	add    $0x8,%edx
8010484a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010484e:	83 ec 0c             	sub    $0xc,%esp
80104851:	50                   	push   %eax
80104852:	e8 da c7 ff ff       	call   80101031 <filedup>
80104857:	83 c4 10             	add    $0x10,%esp
8010485a:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010485d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104860:	83 c1 08             	add    $0x8,%ecx
80104863:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80104867:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
8010486b:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010486f:	7e b9                	jle    8010482a <fork+0xcf>
  np->cwd = idup(proc->cwd);
80104871:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104877:	8b 40 68             	mov    0x68(%eax),%eax
8010487a:	83 ec 0c             	sub    $0xc,%esp
8010487d:	50                   	push   %eax
8010487e:	e8 cc d0 ff ff       	call   8010194f <idup>
80104883:	83 c4 10             	add    $0x10,%esp
80104886:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104889:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
8010488c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104892:	8d 50 6c             	lea    0x6c(%eax),%edx
80104895:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104898:	83 c0 6c             	add    $0x6c,%eax
8010489b:	83 ec 04             	sub    $0x4,%esp
8010489e:	6a 10                	push   $0x10
801048a0:	52                   	push   %edx
801048a1:	50                   	push   %eax
801048a2:	e8 05 0c 00 00       	call   801054ac <safestrcpy>
801048a7:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
801048aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048ad:	8b 40 10             	mov    0x10(%eax),%eax
801048b0:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801048b3:	83 ec 0c             	sub    $0xc,%esp
801048b6:	68 20 19 11 80       	push   $0x80111920
801048bb:	e8 85 07 00 00       	call   80105045 <acquire>
801048c0:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
801048c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048c6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801048cd:	83 ec 0c             	sub    $0xc,%esp
801048d0:	68 20 19 11 80       	push   $0x80111920
801048d5:	e8 d2 07 00 00       	call   801050ac <release>
801048da:	83 c4 10             	add    $0x10,%esp
  
  return pid;
801048dd:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801048e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801048e3:	5b                   	pop    %ebx
801048e4:	5e                   	pop    %esi
801048e5:	5f                   	pop    %edi
801048e6:	5d                   	pop    %ebp
801048e7:	c3                   	ret

801048e8 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801048e8:	55                   	push   %ebp
801048e9:	89 e5                	mov    %esp,%ebp
801048eb:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801048ee:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801048f5:	a1 54 38 11 80       	mov    0x80113854,%eax
801048fa:	39 c2                	cmp    %eax,%edx
801048fc:	75 0d                	jne    8010490b <exit+0x23>
    panic("init exiting");
801048fe:	83 ec 0c             	sub    $0xc,%esp
80104901:	68 cc 88 10 80       	push   $0x801088cc
80104906:	e8 6e bc ff ff       	call   80100579 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010490b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104912:	eb 48                	jmp    8010495c <exit+0x74>
    if(proc->ofile[fd]){
80104914:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010491a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010491d:	83 c2 08             	add    $0x8,%edx
80104920:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104924:	85 c0                	test   %eax,%eax
80104926:	74 30                	je     80104958 <exit+0x70>
      fileclose(proc->ofile[fd]);
80104928:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010492e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104931:	83 c2 08             	add    $0x8,%edx
80104934:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104938:	83 ec 0c             	sub    $0xc,%esp
8010493b:	50                   	push   %eax
8010493c:	e8 41 c7 ff ff       	call   80101082 <fileclose>
80104941:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104944:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010494a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010494d:	83 c2 08             	add    $0x8,%edx
80104950:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104957:	00 
  for(fd = 0; fd < NOFILE; fd++){
80104958:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010495c:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104960:	7e b2                	jle    80104914 <exit+0x2c>
    }
  }

  begin_op();
80104962:	e8 ef eb ff ff       	call   80103556 <begin_op>
  iput(proc->cwd);
80104967:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010496d:	8b 40 68             	mov    0x68(%eax),%eax
80104970:	83 ec 0c             	sub    $0xc,%esp
80104973:	50                   	push   %eax
80104974:	e8 e0 d1 ff ff       	call   80101b59 <iput>
80104979:	83 c4 10             	add    $0x10,%esp
  end_op();
8010497c:	e8 61 ec ff ff       	call   801035e2 <end_op>
  proc->cwd = 0;
80104981:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104987:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010498e:	83 ec 0c             	sub    $0xc,%esp
80104991:	68 20 19 11 80       	push   $0x80111920
80104996:	e8 aa 06 00 00       	call   80105045 <acquire>
8010499b:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
8010499e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049a4:	8b 40 14             	mov    0x14(%eax),%eax
801049a7:	83 ec 0c             	sub    $0xc,%esp
801049aa:	50                   	push   %eax
801049ab:	e8 46 04 00 00       	call   80104df6 <wakeup1>
801049b0:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049b3:	c7 45 f4 54 19 11 80 	movl   $0x80111954,-0xc(%ebp)
801049ba:	eb 3c                	jmp    801049f8 <exit+0x110>
    if(p->parent == proc){
801049bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049bf:	8b 50 14             	mov    0x14(%eax),%edx
801049c2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049c8:	39 c2                	cmp    %eax,%edx
801049ca:	75 28                	jne    801049f4 <exit+0x10c>
      p->parent = initproc;
801049cc:	8b 15 54 38 11 80    	mov    0x80113854,%edx
801049d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d5:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801049d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049db:	8b 40 0c             	mov    0xc(%eax),%eax
801049de:	83 f8 05             	cmp    $0x5,%eax
801049e1:	75 11                	jne    801049f4 <exit+0x10c>
        wakeup1(initproc);
801049e3:	a1 54 38 11 80       	mov    0x80113854,%eax
801049e8:	83 ec 0c             	sub    $0xc,%esp
801049eb:	50                   	push   %eax
801049ec:	e8 05 04 00 00       	call   80104df6 <wakeup1>
801049f1:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049f4:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801049f8:	81 7d f4 54 38 11 80 	cmpl   $0x80113854,-0xc(%ebp)
801049ff:	72 bb                	jb     801049bc <exit+0xd4>
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104a01:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a07:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104a0e:	e8 fa 01 00 00       	call   80104c0d <sched>
  panic("zombie exit");
80104a13:	83 ec 0c             	sub    $0xc,%esp
80104a16:	68 d9 88 10 80       	push   $0x801088d9
80104a1b:	e8 59 bb ff ff       	call   80100579 <panic>

80104a20 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104a20:	55                   	push   %ebp
80104a21:	89 e5                	mov    %esp,%ebp
80104a23:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a26:	83 ec 0c             	sub    $0xc,%esp
80104a29:	68 20 19 11 80       	push   $0x80111920
80104a2e:	e8 12 06 00 00       	call   80105045 <acquire>
80104a33:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a36:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a3d:	c7 45 f4 54 19 11 80 	movl   $0x80111954,-0xc(%ebp)
80104a44:	e9 a6 00 00 00       	jmp    80104aef <wait+0xcf>
      if(p->parent != proc)
80104a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a4c:	8b 50 14             	mov    0x14(%eax),%edx
80104a4f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a55:	39 c2                	cmp    %eax,%edx
80104a57:	0f 85 8d 00 00 00    	jne    80104aea <wait+0xca>
        continue;
      havekids = 1;
80104a5d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a67:	8b 40 0c             	mov    0xc(%eax),%eax
80104a6a:	83 f8 05             	cmp    $0x5,%eax
80104a6d:	75 7c                	jne    80104aeb <wait+0xcb>
        // Found one.
        pid = p->pid;
80104a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a72:	8b 40 10             	mov    0x10(%eax),%eax
80104a75:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a7b:	8b 40 08             	mov    0x8(%eax),%eax
80104a7e:	83 ec 0c             	sub    $0xc,%esp
80104a81:	50                   	push   %eax
80104a82:	e8 55 e1 ff ff       	call   80102bdc <kfree>
80104a87:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a97:	8b 40 04             	mov    0x4(%eax),%eax
80104a9a:	83 ec 0c             	sub    $0xc,%esp
80104a9d:	50                   	push   %eax
80104a9e:	e8 d3 37 00 00       	call   80108276 <freevm>
80104aa3:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab3:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104abd:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac7:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ace:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104ad5:	83 ec 0c             	sub    $0xc,%esp
80104ad8:	68 20 19 11 80       	push   $0x80111920
80104add:	e8 ca 05 00 00       	call   801050ac <release>
80104ae2:	83 c4 10             	add    $0x10,%esp
        return pid;
80104ae5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ae8:	eb 58                	jmp    80104b42 <wait+0x122>
        continue;
80104aea:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104aeb:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104aef:	81 7d f4 54 38 11 80 	cmpl   $0x80113854,-0xc(%ebp)
80104af6:	0f 82 4d ff ff ff    	jb     80104a49 <wait+0x29>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104afc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b00:	74 0d                	je     80104b0f <wait+0xef>
80104b02:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b08:	8b 40 24             	mov    0x24(%eax),%eax
80104b0b:	85 c0                	test   %eax,%eax
80104b0d:	74 17                	je     80104b26 <wait+0x106>
      release(&ptable.lock);
80104b0f:	83 ec 0c             	sub    $0xc,%esp
80104b12:	68 20 19 11 80       	push   $0x80111920
80104b17:	e8 90 05 00 00       	call   801050ac <release>
80104b1c:	83 c4 10             	add    $0x10,%esp
      return -1;
80104b1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b24:	eb 1c                	jmp    80104b42 <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b26:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b2c:	83 ec 08             	sub    $0x8,%esp
80104b2f:	68 20 19 11 80       	push   $0x80111920
80104b34:	50                   	push   %eax
80104b35:	e8 10 02 00 00       	call   80104d4a <sleep>
80104b3a:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104b3d:	e9 f4 fe ff ff       	jmp    80104a36 <wait+0x16>
  }
}
80104b42:	c9                   	leave
80104b43:	c3                   	ret

80104b44 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104b44:	55                   	push   %ebp
80104b45:	89 e5                	mov    %esp,%ebp
80104b47:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int ran = 0; // CS550: to solve the 100%-CPU-utilization-when-idling problem
80104b4a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104b51:	e8 1b f9 ff ff       	call   80104471 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104b56:	83 ec 0c             	sub    $0xc,%esp
80104b59:	68 20 19 11 80       	push   $0x80111920
80104b5e:	e8 e2 04 00 00       	call   80105045 <acquire>
80104b63:	83 c4 10             	add    $0x10,%esp
    ran = 0;
80104b66:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b6d:	c7 45 f4 54 19 11 80 	movl   $0x80111954,-0xc(%ebp)
80104b74:	eb 6a                	jmp    80104be0 <scheduler+0x9c>
      if(p->state != RUNNABLE)
80104b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b79:	8b 40 0c             	mov    0xc(%eax),%eax
80104b7c:	83 f8 03             	cmp    $0x3,%eax
80104b7f:	75 5a                	jne    80104bdb <scheduler+0x97>
        continue;

      ran = 1;
80104b81:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b8b:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104b91:	83 ec 0c             	sub    $0xc,%esp
80104b94:	ff 75 f4             	push   -0xc(%ebp)
80104b97:	e8 95 32 00 00       	call   80107e31 <switchuvm>
80104b9c:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba2:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104ba9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104baf:	8b 40 1c             	mov    0x1c(%eax),%eax
80104bb2:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104bb9:	83 c2 04             	add    $0x4,%edx
80104bbc:	83 ec 08             	sub    $0x8,%esp
80104bbf:	50                   	push   %eax
80104bc0:	52                   	push   %edx
80104bc1:	e8 58 09 00 00       	call   8010551e <swtch>
80104bc6:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104bc9:	e8 46 32 00 00       	call   80107e14 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104bce:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104bd5:	00 00 00 00 
80104bd9:	eb 01                	jmp    80104bdc <scheduler+0x98>
        continue;
80104bdb:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bdc:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104be0:	81 7d f4 54 38 11 80 	cmpl   $0x80113854,-0xc(%ebp)
80104be7:	72 8d                	jb     80104b76 <scheduler+0x32>
    }
    release(&ptable.lock);
80104be9:	83 ec 0c             	sub    $0xc,%esp
80104bec:	68 20 19 11 80       	push   $0x80111920
80104bf1:	e8 b6 04 00 00       	call   801050ac <release>
80104bf6:	83 c4 10             	add    $0x10,%esp

    if (ran == 0){
80104bf9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104bfd:	0f 85 4e ff ff ff    	jne    80104b51 <scheduler+0xd>
        halt();
80104c03:	e8 70 f8 ff ff       	call   80104478 <halt>
    sti();
80104c08:	e9 44 ff ff ff       	jmp    80104b51 <scheduler+0xd>

80104c0d <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104c0d:	55                   	push   %ebp
80104c0e:	89 e5                	mov    %esp,%ebp
80104c10:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80104c13:	83 ec 0c             	sub    $0xc,%esp
80104c16:	68 20 19 11 80       	push   $0x80111920
80104c1b:	e8 59 05 00 00       	call   80105179 <holding>
80104c20:	83 c4 10             	add    $0x10,%esp
80104c23:	85 c0                	test   %eax,%eax
80104c25:	75 0d                	jne    80104c34 <sched+0x27>
    panic("sched ptable.lock");
80104c27:	83 ec 0c             	sub    $0xc,%esp
80104c2a:	68 e5 88 10 80       	push   $0x801088e5
80104c2f:	e8 45 b9 ff ff       	call   80100579 <panic>
  if(cpu->ncli != 1)
80104c34:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c3a:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104c40:	83 f8 01             	cmp    $0x1,%eax
80104c43:	74 0d                	je     80104c52 <sched+0x45>
    panic("sched locks");
80104c45:	83 ec 0c             	sub    $0xc,%esp
80104c48:	68 f7 88 10 80       	push   $0x801088f7
80104c4d:	e8 27 b9 ff ff       	call   80100579 <panic>
  if(proc->state == RUNNING)
80104c52:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c58:	8b 40 0c             	mov    0xc(%eax),%eax
80104c5b:	83 f8 04             	cmp    $0x4,%eax
80104c5e:	75 0d                	jne    80104c6d <sched+0x60>
    panic("sched running");
80104c60:	83 ec 0c             	sub    $0xc,%esp
80104c63:	68 03 89 10 80       	push   $0x80108903
80104c68:	e8 0c b9 ff ff       	call   80100579 <panic>
  if(readeflags()&FL_IF)
80104c6d:	e8 ef f7 ff ff       	call   80104461 <readeflags>
80104c72:	25 00 02 00 00       	and    $0x200,%eax
80104c77:	85 c0                	test   %eax,%eax
80104c79:	74 0d                	je     80104c88 <sched+0x7b>
    panic("sched interruptible");
80104c7b:	83 ec 0c             	sub    $0xc,%esp
80104c7e:	68 11 89 10 80       	push   $0x80108911
80104c83:	e8 f1 b8 ff ff       	call   80100579 <panic>
  intena = cpu->intena;
80104c88:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c8e:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104c94:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104c97:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c9d:	8b 40 04             	mov    0x4(%eax),%eax
80104ca0:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104ca7:	83 c2 1c             	add    $0x1c,%edx
80104caa:	83 ec 08             	sub    $0x8,%esp
80104cad:	50                   	push   %eax
80104cae:	52                   	push   %edx
80104caf:	e8 6a 08 00 00       	call   8010551e <swtch>
80104cb4:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80104cb7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cbd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cc0:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104cc6:	90                   	nop
80104cc7:	c9                   	leave
80104cc8:	c3                   	ret

80104cc9 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104cc9:	55                   	push   %ebp
80104cca:	89 e5                	mov    %esp,%ebp
80104ccc:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104ccf:	83 ec 0c             	sub    $0xc,%esp
80104cd2:	68 20 19 11 80       	push   $0x80111920
80104cd7:	e8 69 03 00 00       	call   80105045 <acquire>
80104cdc:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80104cdf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ce5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104cec:	e8 1c ff ff ff       	call   80104c0d <sched>
  release(&ptable.lock);
80104cf1:	83 ec 0c             	sub    $0xc,%esp
80104cf4:	68 20 19 11 80       	push   $0x80111920
80104cf9:	e8 ae 03 00 00       	call   801050ac <release>
80104cfe:	83 c4 10             	add    $0x10,%esp
}
80104d01:	90                   	nop
80104d02:	c9                   	leave
80104d03:	c3                   	ret

80104d04 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104d04:	55                   	push   %ebp
80104d05:	89 e5                	mov    %esp,%ebp
80104d07:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104d0a:	83 ec 0c             	sub    $0xc,%esp
80104d0d:	68 20 19 11 80       	push   $0x80111920
80104d12:	e8 95 03 00 00       	call   801050ac <release>
80104d17:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104d1a:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104d1f:	85 c0                	test   %eax,%eax
80104d21:	74 24                	je     80104d47 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104d23:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104d2a:	00 00 00 
    iinit(ROOTDEV);
80104d2d:	83 ec 0c             	sub    $0xc,%esp
80104d30:	6a 01                	push   $0x1
80104d32:	e8 27 c9 ff ff       	call   8010165e <iinit>
80104d37:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104d3a:	83 ec 0c             	sub    $0xc,%esp
80104d3d:	6a 01                	push   $0x1
80104d3f:	e8 f3 e5 ff ff       	call   80103337 <initlog>
80104d44:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104d47:	90                   	nop
80104d48:	c9                   	leave
80104d49:	c3                   	ret

80104d4a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104d4a:	55                   	push   %ebp
80104d4b:	89 e5                	mov    %esp,%ebp
80104d4d:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80104d50:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d56:	85 c0                	test   %eax,%eax
80104d58:	75 0d                	jne    80104d67 <sleep+0x1d>
    panic("sleep");
80104d5a:	83 ec 0c             	sub    $0xc,%esp
80104d5d:	68 25 89 10 80       	push   $0x80108925
80104d62:	e8 12 b8 ff ff       	call   80100579 <panic>

  if(lk == 0)
80104d67:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104d6b:	75 0d                	jne    80104d7a <sleep+0x30>
    panic("sleep without lk");
80104d6d:	83 ec 0c             	sub    $0xc,%esp
80104d70:	68 2b 89 10 80       	push   $0x8010892b
80104d75:	e8 ff b7 ff ff       	call   80100579 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104d7a:	81 7d 0c 20 19 11 80 	cmpl   $0x80111920,0xc(%ebp)
80104d81:	74 1e                	je     80104da1 <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104d83:	83 ec 0c             	sub    $0xc,%esp
80104d86:	68 20 19 11 80       	push   $0x80111920
80104d8b:	e8 b5 02 00 00       	call   80105045 <acquire>
80104d90:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104d93:	83 ec 0c             	sub    $0xc,%esp
80104d96:	ff 75 0c             	push   0xc(%ebp)
80104d99:	e8 0e 03 00 00       	call   801050ac <release>
80104d9e:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80104da1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104da7:	8b 55 08             	mov    0x8(%ebp),%edx
80104daa:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104dad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104db3:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104dba:	e8 4e fe ff ff       	call   80104c0d <sched>

  // Tidy up.
  proc->chan = 0;
80104dbf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dc5:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104dcc:	81 7d 0c 20 19 11 80 	cmpl   $0x80111920,0xc(%ebp)
80104dd3:	74 1e                	je     80104df3 <sleep+0xa9>
    release(&ptable.lock);
80104dd5:	83 ec 0c             	sub    $0xc,%esp
80104dd8:	68 20 19 11 80       	push   $0x80111920
80104ddd:	e8 ca 02 00 00       	call   801050ac <release>
80104de2:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104de5:	83 ec 0c             	sub    $0xc,%esp
80104de8:	ff 75 0c             	push   0xc(%ebp)
80104deb:	e8 55 02 00 00       	call   80105045 <acquire>
80104df0:	83 c4 10             	add    $0x10,%esp
  }
}
80104df3:	90                   	nop
80104df4:	c9                   	leave
80104df5:	c3                   	ret

80104df6 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104df6:	55                   	push   %ebp
80104df7:	89 e5                	mov    %esp,%ebp
80104df9:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104dfc:	c7 45 fc 54 19 11 80 	movl   $0x80111954,-0x4(%ebp)
80104e03:	eb 24                	jmp    80104e29 <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104e05:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e08:	8b 40 0c             	mov    0xc(%eax),%eax
80104e0b:	83 f8 02             	cmp    $0x2,%eax
80104e0e:	75 15                	jne    80104e25 <wakeup1+0x2f>
80104e10:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e13:	8b 40 20             	mov    0x20(%eax),%eax
80104e16:	39 45 08             	cmp    %eax,0x8(%ebp)
80104e19:	75 0a                	jne    80104e25 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104e1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e1e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e25:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104e29:	81 7d fc 54 38 11 80 	cmpl   $0x80113854,-0x4(%ebp)
80104e30:	72 d3                	jb     80104e05 <wakeup1+0xf>
}
80104e32:	90                   	nop
80104e33:	90                   	nop
80104e34:	c9                   	leave
80104e35:	c3                   	ret

80104e36 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104e36:	55                   	push   %ebp
80104e37:	89 e5                	mov    %esp,%ebp
80104e39:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104e3c:	83 ec 0c             	sub    $0xc,%esp
80104e3f:	68 20 19 11 80       	push   $0x80111920
80104e44:	e8 fc 01 00 00       	call   80105045 <acquire>
80104e49:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104e4c:	83 ec 0c             	sub    $0xc,%esp
80104e4f:	ff 75 08             	push   0x8(%ebp)
80104e52:	e8 9f ff ff ff       	call   80104df6 <wakeup1>
80104e57:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104e5a:	83 ec 0c             	sub    $0xc,%esp
80104e5d:	68 20 19 11 80       	push   $0x80111920
80104e62:	e8 45 02 00 00       	call   801050ac <release>
80104e67:	83 c4 10             	add    $0x10,%esp
}
80104e6a:	90                   	nop
80104e6b:	c9                   	leave
80104e6c:	c3                   	ret

80104e6d <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104e6d:	55                   	push   %ebp
80104e6e:	89 e5                	mov    %esp,%ebp
80104e70:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104e73:	83 ec 0c             	sub    $0xc,%esp
80104e76:	68 20 19 11 80       	push   $0x80111920
80104e7b:	e8 c5 01 00 00       	call   80105045 <acquire>
80104e80:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104e83:	c7 45 f4 54 19 11 80 	movl   $0x80111954,-0xc(%ebp)
80104e8a:	eb 45                	jmp    80104ed1 <kill+0x64>
    if(p->pid == pid){
80104e8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e8f:	8b 40 10             	mov    0x10(%eax),%eax
80104e92:	39 45 08             	cmp    %eax,0x8(%ebp)
80104e95:	75 36                	jne    80104ecd <kill+0x60>
      p->killed = 1;
80104e97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e9a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ea4:	8b 40 0c             	mov    0xc(%eax),%eax
80104ea7:	83 f8 02             	cmp    $0x2,%eax
80104eaa:	75 0a                	jne    80104eb6 <kill+0x49>
        p->state = RUNNABLE;
80104eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eaf:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104eb6:	83 ec 0c             	sub    $0xc,%esp
80104eb9:	68 20 19 11 80       	push   $0x80111920
80104ebe:	e8 e9 01 00 00       	call   801050ac <release>
80104ec3:	83 c4 10             	add    $0x10,%esp
      return 0;
80104ec6:	b8 00 00 00 00       	mov    $0x0,%eax
80104ecb:	eb 22                	jmp    80104eef <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ecd:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104ed1:	81 7d f4 54 38 11 80 	cmpl   $0x80113854,-0xc(%ebp)
80104ed8:	72 b2                	jb     80104e8c <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104eda:	83 ec 0c             	sub    $0xc,%esp
80104edd:	68 20 19 11 80       	push   $0x80111920
80104ee2:	e8 c5 01 00 00       	call   801050ac <release>
80104ee7:	83 c4 10             	add    $0x10,%esp
  return -1;
80104eea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104eef:	c9                   	leave
80104ef0:	c3                   	ret

80104ef1 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104ef1:	55                   	push   %ebp
80104ef2:	89 e5                	mov    %esp,%ebp
80104ef4:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ef7:	c7 45 f0 54 19 11 80 	movl   $0x80111954,-0x10(%ebp)
80104efe:	e9 d7 00 00 00       	jmp    80104fda <procdump+0xe9>
    if(p->state == UNUSED)
80104f03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f06:	8b 40 0c             	mov    0xc(%eax),%eax
80104f09:	85 c0                	test   %eax,%eax
80104f0b:	0f 84 c4 00 00 00    	je     80104fd5 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104f11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f14:	8b 40 0c             	mov    0xc(%eax),%eax
80104f17:	83 f8 05             	cmp    $0x5,%eax
80104f1a:	77 23                	ja     80104f3f <procdump+0x4e>
80104f1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f1f:	8b 40 0c             	mov    0xc(%eax),%eax
80104f22:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104f29:	85 c0                	test   %eax,%eax
80104f2b:	74 12                	je     80104f3f <procdump+0x4e>
      state = states[p->state];
80104f2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f30:	8b 40 0c             	mov    0xc(%eax),%eax
80104f33:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104f3a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104f3d:	eb 07                	jmp    80104f46 <procdump+0x55>
    else
      state = "???";
80104f3f:	c7 45 ec 3c 89 10 80 	movl   $0x8010893c,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104f46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f49:	8d 50 6c             	lea    0x6c(%eax),%edx
80104f4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f4f:	8b 40 10             	mov    0x10(%eax),%eax
80104f52:	52                   	push   %edx
80104f53:	ff 75 ec             	push   -0x14(%ebp)
80104f56:	50                   	push   %eax
80104f57:	68 40 89 10 80       	push   $0x80108940
80104f5c:	e8 63 b4 ff ff       	call   801003c4 <cprintf>
80104f61:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104f64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f67:	8b 40 0c             	mov    0xc(%eax),%eax
80104f6a:	83 f8 02             	cmp    $0x2,%eax
80104f6d:	75 54                	jne    80104fc3 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104f6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f72:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f75:	8b 40 0c             	mov    0xc(%eax),%eax
80104f78:	83 c0 08             	add    $0x8,%eax
80104f7b:	89 c2                	mov    %eax,%edx
80104f7d:	83 ec 08             	sub    $0x8,%esp
80104f80:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104f83:	50                   	push   %eax
80104f84:	52                   	push   %edx
80104f85:	e8 74 01 00 00       	call   801050fe <getcallerpcs>
80104f8a:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104f8d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f94:	eb 1c                	jmp    80104fb2 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104f96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f99:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104f9d:	83 ec 08             	sub    $0x8,%esp
80104fa0:	50                   	push   %eax
80104fa1:	68 49 89 10 80       	push   $0x80108949
80104fa6:	e8 19 b4 ff ff       	call   801003c4 <cprintf>
80104fab:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104fae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104fb2:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104fb6:	7f 0b                	jg     80104fc3 <procdump+0xd2>
80104fb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fbb:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104fbf:	85 c0                	test   %eax,%eax
80104fc1:	75 d3                	jne    80104f96 <procdump+0xa5>
    }
    cprintf("\n");
80104fc3:	83 ec 0c             	sub    $0xc,%esp
80104fc6:	68 4d 89 10 80       	push   $0x8010894d
80104fcb:	e8 f4 b3 ff ff       	call   801003c4 <cprintf>
80104fd0:	83 c4 10             	add    $0x10,%esp
80104fd3:	eb 01                	jmp    80104fd6 <procdump+0xe5>
      continue;
80104fd5:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fd6:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
80104fda:	81 7d f0 54 38 11 80 	cmpl   $0x80113854,-0x10(%ebp)
80104fe1:	0f 82 1c ff ff ff    	jb     80104f03 <procdump+0x12>
  }
}
80104fe7:	90                   	nop
80104fe8:	90                   	nop
80104fe9:	c9                   	leave
80104fea:	c3                   	ret

80104feb <readeflags>:
{
80104feb:	55                   	push   %ebp
80104fec:	89 e5                	mov    %esp,%ebp
80104fee:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104ff1:	9c                   	pushf
80104ff2:	58                   	pop    %eax
80104ff3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104ff6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104ff9:	c9                   	leave
80104ffa:	c3                   	ret

80104ffb <cli>:
{
80104ffb:	55                   	push   %ebp
80104ffc:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80104ffe:	fa                   	cli
}
80104fff:	90                   	nop
80105000:	5d                   	pop    %ebp
80105001:	c3                   	ret

80105002 <sti>:
{
80105002:	55                   	push   %ebp
80105003:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105005:	fb                   	sti
}
80105006:	90                   	nop
80105007:	5d                   	pop    %ebp
80105008:	c3                   	ret

80105009 <xchg>:
{
80105009:	55                   	push   %ebp
8010500a:	89 e5                	mov    %esp,%ebp
8010500c:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
8010500f:	8b 55 08             	mov    0x8(%ebp),%edx
80105012:	8b 45 0c             	mov    0xc(%ebp),%eax
80105015:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105018:	f0 87 02             	lock xchg %eax,(%edx)
8010501b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
8010501e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105021:	c9                   	leave
80105022:	c3                   	ret

80105023 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105023:	55                   	push   %ebp
80105024:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105026:	8b 45 08             	mov    0x8(%ebp),%eax
80105029:	8b 55 0c             	mov    0xc(%ebp),%edx
8010502c:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010502f:	8b 45 08             	mov    0x8(%ebp),%eax
80105032:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105038:	8b 45 08             	mov    0x8(%ebp),%eax
8010503b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105042:	90                   	nop
80105043:	5d                   	pop    %ebp
80105044:	c3                   	ret

80105045 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105045:	55                   	push   %ebp
80105046:	89 e5                	mov    %esp,%ebp
80105048:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010504b:	e8 53 01 00 00       	call   801051a3 <pushcli>
  if(holding(lk))
80105050:	8b 45 08             	mov    0x8(%ebp),%eax
80105053:	83 ec 0c             	sub    $0xc,%esp
80105056:	50                   	push   %eax
80105057:	e8 1d 01 00 00       	call   80105179 <holding>
8010505c:	83 c4 10             	add    $0x10,%esp
8010505f:	85 c0                	test   %eax,%eax
80105061:	74 0d                	je     80105070 <acquire+0x2b>
    panic("acquire");
80105063:	83 ec 0c             	sub    $0xc,%esp
80105066:	68 79 89 10 80       	push   $0x80108979
8010506b:	e8 09 b5 ff ff       	call   80100579 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
80105070:	90                   	nop
80105071:	8b 45 08             	mov    0x8(%ebp),%eax
80105074:	83 ec 08             	sub    $0x8,%esp
80105077:	6a 01                	push   $0x1
80105079:	50                   	push   %eax
8010507a:	e8 8a ff ff ff       	call   80105009 <xchg>
8010507f:	83 c4 10             	add    $0x10,%esp
80105082:	85 c0                	test   %eax,%eax
80105084:	75 eb                	jne    80105071 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
80105086:	8b 45 08             	mov    0x8(%ebp),%eax
80105089:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80105090:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
80105093:	8b 45 08             	mov    0x8(%ebp),%eax
80105096:	83 c0 0c             	add    $0xc,%eax
80105099:	83 ec 08             	sub    $0x8,%esp
8010509c:	50                   	push   %eax
8010509d:	8d 45 08             	lea    0x8(%ebp),%eax
801050a0:	50                   	push   %eax
801050a1:	e8 58 00 00 00       	call   801050fe <getcallerpcs>
801050a6:	83 c4 10             	add    $0x10,%esp
}
801050a9:	90                   	nop
801050aa:	c9                   	leave
801050ab:	c3                   	ret

801050ac <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801050ac:	55                   	push   %ebp
801050ad:	89 e5                	mov    %esp,%ebp
801050af:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801050b2:	83 ec 0c             	sub    $0xc,%esp
801050b5:	ff 75 08             	push   0x8(%ebp)
801050b8:	e8 bc 00 00 00       	call   80105179 <holding>
801050bd:	83 c4 10             	add    $0x10,%esp
801050c0:	85 c0                	test   %eax,%eax
801050c2:	75 0d                	jne    801050d1 <release+0x25>
    panic("release");
801050c4:	83 ec 0c             	sub    $0xc,%esp
801050c7:	68 81 89 10 80       	push   $0x80108981
801050cc:	e8 a8 b4 ff ff       	call   80100579 <panic>

  lk->pcs[0] = 0;
801050d1:	8b 45 08             	mov    0x8(%ebp),%eax
801050d4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801050db:	8b 45 08             	mov    0x8(%ebp),%eax
801050de:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
801050e5:	8b 45 08             	mov    0x8(%ebp),%eax
801050e8:	83 ec 08             	sub    $0x8,%esp
801050eb:	6a 00                	push   $0x0
801050ed:	50                   	push   %eax
801050ee:	e8 16 ff ff ff       	call   80105009 <xchg>
801050f3:	83 c4 10             	add    $0x10,%esp

  popcli();
801050f6:	e8 ed 00 00 00       	call   801051e8 <popcli>
}
801050fb:	90                   	nop
801050fc:	c9                   	leave
801050fd:	c3                   	ret

801050fe <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801050fe:	55                   	push   %ebp
801050ff:	89 e5                	mov    %esp,%ebp
80105101:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105104:	8b 45 08             	mov    0x8(%ebp),%eax
80105107:	83 e8 08             	sub    $0x8,%eax
8010510a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010510d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105114:	eb 38                	jmp    8010514e <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105116:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010511a:	74 53                	je     8010516f <getcallerpcs+0x71>
8010511c:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105123:	76 4a                	jbe    8010516f <getcallerpcs+0x71>
80105125:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105129:	74 44                	je     8010516f <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010512b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010512e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105135:	8b 45 0c             	mov    0xc(%ebp),%eax
80105138:	01 c2                	add    %eax,%edx
8010513a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010513d:	8b 40 04             	mov    0x4(%eax),%eax
80105140:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105142:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105145:	8b 00                	mov    (%eax),%eax
80105147:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010514a:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010514e:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105152:	7e c2                	jle    80105116 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80105154:	eb 19                	jmp    8010516f <getcallerpcs+0x71>
    pcs[i] = 0;
80105156:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105159:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105160:	8b 45 0c             	mov    0xc(%ebp),%eax
80105163:	01 d0                	add    %edx,%eax
80105165:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
8010516b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010516f:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105173:	7e e1                	jle    80105156 <getcallerpcs+0x58>
}
80105175:	90                   	nop
80105176:	90                   	nop
80105177:	c9                   	leave
80105178:	c3                   	ret

80105179 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105179:	55                   	push   %ebp
8010517a:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
8010517c:	8b 45 08             	mov    0x8(%ebp),%eax
8010517f:	8b 00                	mov    (%eax),%eax
80105181:	85 c0                	test   %eax,%eax
80105183:	74 17                	je     8010519c <holding+0x23>
80105185:	8b 45 08             	mov    0x8(%ebp),%eax
80105188:	8b 50 08             	mov    0x8(%eax),%edx
8010518b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105191:	39 c2                	cmp    %eax,%edx
80105193:	75 07                	jne    8010519c <holding+0x23>
80105195:	b8 01 00 00 00       	mov    $0x1,%eax
8010519a:	eb 05                	jmp    801051a1 <holding+0x28>
8010519c:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051a1:	5d                   	pop    %ebp
801051a2:	c3                   	ret

801051a3 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801051a3:	55                   	push   %ebp
801051a4:	89 e5                	mov    %esp,%ebp
801051a6:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
801051a9:	e8 3d fe ff ff       	call   80104feb <readeflags>
801051ae:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
801051b1:	e8 45 fe ff ff       	call   80104ffb <cli>
  if(cpu->ncli++ == 0)
801051b6:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801051bd:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
801051c3:	8d 48 01             	lea    0x1(%eax),%ecx
801051c6:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
801051cc:	85 c0                	test   %eax,%eax
801051ce:	75 15                	jne    801051e5 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
801051d0:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051d6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801051d9:	81 e2 00 02 00 00    	and    $0x200,%edx
801051df:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
801051e5:	90                   	nop
801051e6:	c9                   	leave
801051e7:	c3                   	ret

801051e8 <popcli>:

void
popcli(void)
{
801051e8:	55                   	push   %ebp
801051e9:	89 e5                	mov    %esp,%ebp
801051eb:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801051ee:	e8 f8 fd ff ff       	call   80104feb <readeflags>
801051f3:	25 00 02 00 00       	and    $0x200,%eax
801051f8:	85 c0                	test   %eax,%eax
801051fa:	74 0d                	je     80105209 <popcli+0x21>
    panic("popcli - interruptible");
801051fc:	83 ec 0c             	sub    $0xc,%esp
801051ff:	68 89 89 10 80       	push   $0x80108989
80105204:	e8 70 b3 ff ff       	call   80100579 <panic>
  if(--cpu->ncli < 0)
80105209:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010520f:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105215:	83 ea 01             	sub    $0x1,%edx
80105218:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
8010521e:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105224:	85 c0                	test   %eax,%eax
80105226:	79 0d                	jns    80105235 <popcli+0x4d>
    panic("popcli");
80105228:	83 ec 0c             	sub    $0xc,%esp
8010522b:	68 a0 89 10 80       	push   $0x801089a0
80105230:	e8 44 b3 ff ff       	call   80100579 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105235:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010523b:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105241:	85 c0                	test   %eax,%eax
80105243:	75 15                	jne    8010525a <popcli+0x72>
80105245:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010524b:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105251:	85 c0                	test   %eax,%eax
80105253:	74 05                	je     8010525a <popcli+0x72>
    sti();
80105255:	e8 a8 fd ff ff       	call   80105002 <sti>
}
8010525a:	90                   	nop
8010525b:	c9                   	leave
8010525c:	c3                   	ret

8010525d <stosb>:
{
8010525d:	55                   	push   %ebp
8010525e:	89 e5                	mov    %esp,%ebp
80105260:	57                   	push   %edi
80105261:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105262:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105265:	8b 55 10             	mov    0x10(%ebp),%edx
80105268:	8b 45 0c             	mov    0xc(%ebp),%eax
8010526b:	89 cb                	mov    %ecx,%ebx
8010526d:	89 df                	mov    %ebx,%edi
8010526f:	89 d1                	mov    %edx,%ecx
80105271:	fc                   	cld
80105272:	f3 aa                	rep stos %al,%es:(%edi)
80105274:	89 ca                	mov    %ecx,%edx
80105276:	89 fb                	mov    %edi,%ebx
80105278:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010527b:	89 55 10             	mov    %edx,0x10(%ebp)
}
8010527e:	90                   	nop
8010527f:	5b                   	pop    %ebx
80105280:	5f                   	pop    %edi
80105281:	5d                   	pop    %ebp
80105282:	c3                   	ret

80105283 <stosl>:
{
80105283:	55                   	push   %ebp
80105284:	89 e5                	mov    %esp,%ebp
80105286:	57                   	push   %edi
80105287:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105288:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010528b:	8b 55 10             	mov    0x10(%ebp),%edx
8010528e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105291:	89 cb                	mov    %ecx,%ebx
80105293:	89 df                	mov    %ebx,%edi
80105295:	89 d1                	mov    %edx,%ecx
80105297:	fc                   	cld
80105298:	f3 ab                	rep stos %eax,%es:(%edi)
8010529a:	89 ca                	mov    %ecx,%edx
8010529c:	89 fb                	mov    %edi,%ebx
8010529e:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052a1:	89 55 10             	mov    %edx,0x10(%ebp)
}
801052a4:	90                   	nop
801052a5:	5b                   	pop    %ebx
801052a6:	5f                   	pop    %edi
801052a7:	5d                   	pop    %ebp
801052a8:	c3                   	ret

801052a9 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801052a9:	55                   	push   %ebp
801052aa:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801052ac:	8b 45 08             	mov    0x8(%ebp),%eax
801052af:	83 e0 03             	and    $0x3,%eax
801052b2:	85 c0                	test   %eax,%eax
801052b4:	75 43                	jne    801052f9 <memset+0x50>
801052b6:	8b 45 10             	mov    0x10(%ebp),%eax
801052b9:	83 e0 03             	and    $0x3,%eax
801052bc:	85 c0                	test   %eax,%eax
801052be:	75 39                	jne    801052f9 <memset+0x50>
    c &= 0xFF;
801052c0:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801052c7:	8b 45 10             	mov    0x10(%ebp),%eax
801052ca:	c1 e8 02             	shr    $0x2,%eax
801052cd:	89 c1                	mov    %eax,%ecx
801052cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801052d2:	c1 e0 18             	shl    $0x18,%eax
801052d5:	89 c2                	mov    %eax,%edx
801052d7:	8b 45 0c             	mov    0xc(%ebp),%eax
801052da:	c1 e0 10             	shl    $0x10,%eax
801052dd:	09 c2                	or     %eax,%edx
801052df:	8b 45 0c             	mov    0xc(%ebp),%eax
801052e2:	c1 e0 08             	shl    $0x8,%eax
801052e5:	09 d0                	or     %edx,%eax
801052e7:	0b 45 0c             	or     0xc(%ebp),%eax
801052ea:	51                   	push   %ecx
801052eb:	50                   	push   %eax
801052ec:	ff 75 08             	push   0x8(%ebp)
801052ef:	e8 8f ff ff ff       	call   80105283 <stosl>
801052f4:	83 c4 0c             	add    $0xc,%esp
801052f7:	eb 12                	jmp    8010530b <memset+0x62>
  } else
    stosb(dst, c, n);
801052f9:	8b 45 10             	mov    0x10(%ebp),%eax
801052fc:	50                   	push   %eax
801052fd:	ff 75 0c             	push   0xc(%ebp)
80105300:	ff 75 08             	push   0x8(%ebp)
80105303:	e8 55 ff ff ff       	call   8010525d <stosb>
80105308:	83 c4 0c             	add    $0xc,%esp
  return dst;
8010530b:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010530e:	c9                   	leave
8010530f:	c3                   	ret

80105310 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105310:	55                   	push   %ebp
80105311:	89 e5                	mov    %esp,%ebp
80105313:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105316:	8b 45 08             	mov    0x8(%ebp),%eax
80105319:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010531c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010531f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105322:	eb 2e                	jmp    80105352 <memcmp+0x42>
    if(*s1 != *s2)
80105324:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105327:	0f b6 10             	movzbl (%eax),%edx
8010532a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010532d:	0f b6 00             	movzbl (%eax),%eax
80105330:	38 c2                	cmp    %al,%dl
80105332:	74 16                	je     8010534a <memcmp+0x3a>
      return *s1 - *s2;
80105334:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105337:	0f b6 00             	movzbl (%eax),%eax
8010533a:	0f b6 d0             	movzbl %al,%edx
8010533d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105340:	0f b6 00             	movzbl (%eax),%eax
80105343:	0f b6 c0             	movzbl %al,%eax
80105346:	29 c2                	sub    %eax,%edx
80105348:	eb 1a                	jmp    80105364 <memcmp+0x54>
    s1++, s2++;
8010534a:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010534e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105352:	8b 45 10             	mov    0x10(%ebp),%eax
80105355:	8d 50 ff             	lea    -0x1(%eax),%edx
80105358:	89 55 10             	mov    %edx,0x10(%ebp)
8010535b:	85 c0                	test   %eax,%eax
8010535d:	75 c5                	jne    80105324 <memcmp+0x14>
  }

  return 0;
8010535f:	ba 00 00 00 00       	mov    $0x0,%edx
}
80105364:	89 d0                	mov    %edx,%eax
80105366:	c9                   	leave
80105367:	c3                   	ret

80105368 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105368:	55                   	push   %ebp
80105369:	89 e5                	mov    %esp,%ebp
8010536b:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010536e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105371:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105374:	8b 45 08             	mov    0x8(%ebp),%eax
80105377:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010537a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010537d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105380:	73 54                	jae    801053d6 <memmove+0x6e>
80105382:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105385:	8b 45 10             	mov    0x10(%ebp),%eax
80105388:	01 d0                	add    %edx,%eax
8010538a:	39 45 f8             	cmp    %eax,-0x8(%ebp)
8010538d:	73 47                	jae    801053d6 <memmove+0x6e>
    s += n;
8010538f:	8b 45 10             	mov    0x10(%ebp),%eax
80105392:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105395:	8b 45 10             	mov    0x10(%ebp),%eax
80105398:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
8010539b:	eb 13                	jmp    801053b0 <memmove+0x48>
      *--d = *--s;
8010539d:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801053a1:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801053a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053a8:	0f b6 10             	movzbl (%eax),%edx
801053ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053ae:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801053b0:	8b 45 10             	mov    0x10(%ebp),%eax
801053b3:	8d 50 ff             	lea    -0x1(%eax),%edx
801053b6:	89 55 10             	mov    %edx,0x10(%ebp)
801053b9:	85 c0                	test   %eax,%eax
801053bb:	75 e0                	jne    8010539d <memmove+0x35>
  if(s < d && s + n > d){
801053bd:	eb 24                	jmp    801053e3 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
801053bf:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053c2:	8d 42 01             	lea    0x1(%edx),%eax
801053c5:	89 45 fc             	mov    %eax,-0x4(%ebp)
801053c8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053cb:	8d 48 01             	lea    0x1(%eax),%ecx
801053ce:	89 4d f8             	mov    %ecx,-0x8(%ebp)
801053d1:	0f b6 12             	movzbl (%edx),%edx
801053d4:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801053d6:	8b 45 10             	mov    0x10(%ebp),%eax
801053d9:	8d 50 ff             	lea    -0x1(%eax),%edx
801053dc:	89 55 10             	mov    %edx,0x10(%ebp)
801053df:	85 c0                	test   %eax,%eax
801053e1:	75 dc                	jne    801053bf <memmove+0x57>

  return dst;
801053e3:	8b 45 08             	mov    0x8(%ebp),%eax
}
801053e6:	c9                   	leave
801053e7:	c3                   	ret

801053e8 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801053e8:	55                   	push   %ebp
801053e9:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801053eb:	ff 75 10             	push   0x10(%ebp)
801053ee:	ff 75 0c             	push   0xc(%ebp)
801053f1:	ff 75 08             	push   0x8(%ebp)
801053f4:	e8 6f ff ff ff       	call   80105368 <memmove>
801053f9:	83 c4 0c             	add    $0xc,%esp
}
801053fc:	c9                   	leave
801053fd:	c3                   	ret

801053fe <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801053fe:	55                   	push   %ebp
801053ff:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105401:	eb 0c                	jmp    8010540f <strncmp+0x11>
    n--, p++, q++;
80105403:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105407:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010540b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
8010540f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105413:	74 1a                	je     8010542f <strncmp+0x31>
80105415:	8b 45 08             	mov    0x8(%ebp),%eax
80105418:	0f b6 00             	movzbl (%eax),%eax
8010541b:	84 c0                	test   %al,%al
8010541d:	74 10                	je     8010542f <strncmp+0x31>
8010541f:	8b 45 08             	mov    0x8(%ebp),%eax
80105422:	0f b6 10             	movzbl (%eax),%edx
80105425:	8b 45 0c             	mov    0xc(%ebp),%eax
80105428:	0f b6 00             	movzbl (%eax),%eax
8010542b:	38 c2                	cmp    %al,%dl
8010542d:	74 d4                	je     80105403 <strncmp+0x5>
  if(n == 0)
8010542f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105433:	75 07                	jne    8010543c <strncmp+0x3e>
    return 0;
80105435:	ba 00 00 00 00       	mov    $0x0,%edx
8010543a:	eb 14                	jmp    80105450 <strncmp+0x52>
  return (uchar)*p - (uchar)*q;
8010543c:	8b 45 08             	mov    0x8(%ebp),%eax
8010543f:	0f b6 00             	movzbl (%eax),%eax
80105442:	0f b6 d0             	movzbl %al,%edx
80105445:	8b 45 0c             	mov    0xc(%ebp),%eax
80105448:	0f b6 00             	movzbl (%eax),%eax
8010544b:	0f b6 c0             	movzbl %al,%eax
8010544e:	29 c2                	sub    %eax,%edx
}
80105450:	89 d0                	mov    %edx,%eax
80105452:	5d                   	pop    %ebp
80105453:	c3                   	ret

80105454 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105454:	55                   	push   %ebp
80105455:	89 e5                	mov    %esp,%ebp
80105457:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010545a:	8b 45 08             	mov    0x8(%ebp),%eax
8010545d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105460:	90                   	nop
80105461:	8b 45 10             	mov    0x10(%ebp),%eax
80105464:	8d 50 ff             	lea    -0x1(%eax),%edx
80105467:	89 55 10             	mov    %edx,0x10(%ebp)
8010546a:	85 c0                	test   %eax,%eax
8010546c:	7e 2c                	jle    8010549a <strncpy+0x46>
8010546e:	8b 55 0c             	mov    0xc(%ebp),%edx
80105471:	8d 42 01             	lea    0x1(%edx),%eax
80105474:	89 45 0c             	mov    %eax,0xc(%ebp)
80105477:	8b 45 08             	mov    0x8(%ebp),%eax
8010547a:	8d 48 01             	lea    0x1(%eax),%ecx
8010547d:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105480:	0f b6 12             	movzbl (%edx),%edx
80105483:	88 10                	mov    %dl,(%eax)
80105485:	0f b6 00             	movzbl (%eax),%eax
80105488:	84 c0                	test   %al,%al
8010548a:	75 d5                	jne    80105461 <strncpy+0xd>
    ;
  while(n-- > 0)
8010548c:	eb 0c                	jmp    8010549a <strncpy+0x46>
    *s++ = 0;
8010548e:	8b 45 08             	mov    0x8(%ebp),%eax
80105491:	8d 50 01             	lea    0x1(%eax),%edx
80105494:	89 55 08             	mov    %edx,0x8(%ebp)
80105497:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
8010549a:	8b 45 10             	mov    0x10(%ebp),%eax
8010549d:	8d 50 ff             	lea    -0x1(%eax),%edx
801054a0:	89 55 10             	mov    %edx,0x10(%ebp)
801054a3:	85 c0                	test   %eax,%eax
801054a5:	7f e7                	jg     8010548e <strncpy+0x3a>
  return os;
801054a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054aa:	c9                   	leave
801054ab:	c3                   	ret

801054ac <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801054ac:	55                   	push   %ebp
801054ad:	89 e5                	mov    %esp,%ebp
801054af:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801054b2:	8b 45 08             	mov    0x8(%ebp),%eax
801054b5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801054b8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054bc:	7f 05                	jg     801054c3 <safestrcpy+0x17>
    return os;
801054be:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054c1:	eb 32                	jmp    801054f5 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
801054c3:	90                   	nop
801054c4:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
801054c8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054cc:	7e 1e                	jle    801054ec <safestrcpy+0x40>
801054ce:	8b 55 0c             	mov    0xc(%ebp),%edx
801054d1:	8d 42 01             	lea    0x1(%edx),%eax
801054d4:	89 45 0c             	mov    %eax,0xc(%ebp)
801054d7:	8b 45 08             	mov    0x8(%ebp),%eax
801054da:	8d 48 01             	lea    0x1(%eax),%ecx
801054dd:	89 4d 08             	mov    %ecx,0x8(%ebp)
801054e0:	0f b6 12             	movzbl (%edx),%edx
801054e3:	88 10                	mov    %dl,(%eax)
801054e5:	0f b6 00             	movzbl (%eax),%eax
801054e8:	84 c0                	test   %al,%al
801054ea:	75 d8                	jne    801054c4 <safestrcpy+0x18>
    ;
  *s = 0;
801054ec:	8b 45 08             	mov    0x8(%ebp),%eax
801054ef:	c6 00 00             	movb   $0x0,(%eax)
  return os;
801054f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054f5:	c9                   	leave
801054f6:	c3                   	ret

801054f7 <strlen>:

int
strlen(const char *s)
{
801054f7:	55                   	push   %ebp
801054f8:	89 e5                	mov    %esp,%ebp
801054fa:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
801054fd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105504:	eb 04                	jmp    8010550a <strlen+0x13>
80105506:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010550a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010550d:	8b 45 08             	mov    0x8(%ebp),%eax
80105510:	01 d0                	add    %edx,%eax
80105512:	0f b6 00             	movzbl (%eax),%eax
80105515:	84 c0                	test   %al,%al
80105517:	75 ed                	jne    80105506 <strlen+0xf>
    ;
  return n;
80105519:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010551c:	c9                   	leave
8010551d:	c3                   	ret

8010551e <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010551e:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105522:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105526:	55                   	push   %ebp
  pushl %ebx
80105527:	53                   	push   %ebx
  pushl %esi
80105528:	56                   	push   %esi
  pushl %edi
80105529:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010552a:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010552c:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010552e:	5f                   	pop    %edi
  popl %esi
8010552f:	5e                   	pop    %esi
  popl %ebx
80105530:	5b                   	pop    %ebx
  popl %ebp
80105531:	5d                   	pop    %ebp
  ret
80105532:	c3                   	ret

80105533 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105533:	55                   	push   %ebp
80105534:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105536:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010553c:	8b 00                	mov    (%eax),%eax
8010553e:	39 45 08             	cmp    %eax,0x8(%ebp)
80105541:	73 12                	jae    80105555 <fetchint+0x22>
80105543:	8b 45 08             	mov    0x8(%ebp),%eax
80105546:	8d 50 04             	lea    0x4(%eax),%edx
80105549:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010554f:	8b 00                	mov    (%eax),%eax
80105551:	39 d0                	cmp    %edx,%eax
80105553:	73 07                	jae    8010555c <fetchint+0x29>
    return -1;
80105555:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010555a:	eb 0f                	jmp    8010556b <fetchint+0x38>
  *ip = *(int*)(addr);
8010555c:	8b 45 08             	mov    0x8(%ebp),%eax
8010555f:	8b 10                	mov    (%eax),%edx
80105561:	8b 45 0c             	mov    0xc(%ebp),%eax
80105564:	89 10                	mov    %edx,(%eax)
  return 0;
80105566:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010556b:	5d                   	pop    %ebp
8010556c:	c3                   	ret

8010556d <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010556d:	55                   	push   %ebp
8010556e:	89 e5                	mov    %esp,%ebp
80105570:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105573:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105579:	8b 00                	mov    (%eax),%eax
8010557b:	39 45 08             	cmp    %eax,0x8(%ebp)
8010557e:	72 07                	jb     80105587 <fetchstr+0x1a>
    return -1;
80105580:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105585:	eb 44                	jmp    801055cb <fetchstr+0x5e>
  *pp = (char*)addr;
80105587:	8b 55 08             	mov    0x8(%ebp),%edx
8010558a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010558d:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
8010558f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105595:	8b 00                	mov    (%eax),%eax
80105597:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
8010559a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010559d:	8b 00                	mov    (%eax),%eax
8010559f:	89 45 fc             	mov    %eax,-0x4(%ebp)
801055a2:	eb 1a                	jmp    801055be <fetchstr+0x51>
    if(*s == 0)
801055a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055a7:	0f b6 00             	movzbl (%eax),%eax
801055aa:	84 c0                	test   %al,%al
801055ac:	75 0c                	jne    801055ba <fetchstr+0x4d>
      return s - *pp;
801055ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801055b1:	8b 10                	mov    (%eax),%edx
801055b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055b6:	29 d0                	sub    %edx,%eax
801055b8:	eb 11                	jmp    801055cb <fetchstr+0x5e>
  for(s = *pp; s < ep; s++)
801055ba:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801055be:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055c1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801055c4:	72 de                	jb     801055a4 <fetchstr+0x37>
  return -1;
801055c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801055cb:	c9                   	leave
801055cc:	c3                   	ret

801055cd <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801055cd:	55                   	push   %ebp
801055ce:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
801055d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055d6:	8b 40 18             	mov    0x18(%eax),%eax
801055d9:	8b 40 44             	mov    0x44(%eax),%eax
801055dc:	8b 55 08             	mov    0x8(%ebp),%edx
801055df:	c1 e2 02             	shl    $0x2,%edx
801055e2:	01 d0                	add    %edx,%eax
801055e4:	83 c0 04             	add    $0x4,%eax
801055e7:	ff 75 0c             	push   0xc(%ebp)
801055ea:	50                   	push   %eax
801055eb:	e8 43 ff ff ff       	call   80105533 <fetchint>
801055f0:	83 c4 08             	add    $0x8,%esp
}
801055f3:	c9                   	leave
801055f4:	c3                   	ret

801055f5 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
801055f5:	55                   	push   %ebp
801055f6:	89 e5                	mov    %esp,%ebp
801055f8:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
801055fb:	8d 45 fc             	lea    -0x4(%ebp),%eax
801055fe:	50                   	push   %eax
801055ff:	ff 75 08             	push   0x8(%ebp)
80105602:	e8 c6 ff ff ff       	call   801055cd <argint>
80105607:	83 c4 08             	add    $0x8,%esp
8010560a:	85 c0                	test   %eax,%eax
8010560c:	79 07                	jns    80105615 <argptr+0x20>
    return -1;
8010560e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105613:	eb 3b                	jmp    80105650 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105615:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010561b:	8b 00                	mov    (%eax),%eax
8010561d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105620:	39 c2                	cmp    %eax,%edx
80105622:	73 16                	jae    8010563a <argptr+0x45>
80105624:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105627:	89 c2                	mov    %eax,%edx
80105629:	8b 45 10             	mov    0x10(%ebp),%eax
8010562c:	01 c2                	add    %eax,%edx
8010562e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105634:	8b 00                	mov    (%eax),%eax
80105636:	39 d0                	cmp    %edx,%eax
80105638:	73 07                	jae    80105641 <argptr+0x4c>
    return -1;
8010563a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010563f:	eb 0f                	jmp    80105650 <argptr+0x5b>
  *pp = (char*)i;
80105641:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105644:	89 c2                	mov    %eax,%edx
80105646:	8b 45 0c             	mov    0xc(%ebp),%eax
80105649:	89 10                	mov    %edx,(%eax)
  return 0;
8010564b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105650:	c9                   	leave
80105651:	c3                   	ret

80105652 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105652:	55                   	push   %ebp
80105653:	89 e5                	mov    %esp,%ebp
80105655:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105658:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010565b:	50                   	push   %eax
8010565c:	ff 75 08             	push   0x8(%ebp)
8010565f:	e8 69 ff ff ff       	call   801055cd <argint>
80105664:	83 c4 08             	add    $0x8,%esp
80105667:	85 c0                	test   %eax,%eax
80105669:	79 07                	jns    80105672 <argstr+0x20>
    return -1;
8010566b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105670:	eb 0f                	jmp    80105681 <argstr+0x2f>
  return fetchstr(addr, pp);
80105672:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105675:	ff 75 0c             	push   0xc(%ebp)
80105678:	50                   	push   %eax
80105679:	e8 ef fe ff ff       	call   8010556d <fetchstr>
8010567e:	83 c4 08             	add    $0x8,%esp
}
80105681:	c9                   	leave
80105682:	c3                   	ret

80105683 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
80105683:	55                   	push   %ebp
80105684:	89 e5                	mov    %esp,%ebp
80105686:	83 ec 18             	sub    $0x18,%esp
  int num;

  num = proc->tf->eax;
80105689:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010568f:	8b 40 18             	mov    0x18(%eax),%eax
80105692:	8b 40 1c             	mov    0x1c(%eax),%eax
80105695:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105698:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010569c:	7e 32                	jle    801056d0 <syscall+0x4d>
8010569e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056a1:	83 f8 15             	cmp    $0x15,%eax
801056a4:	77 2a                	ja     801056d0 <syscall+0x4d>
801056a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056a9:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801056b0:	85 c0                	test   %eax,%eax
801056b2:	74 1c                	je     801056d0 <syscall+0x4d>
    proc->tf->eax = syscalls[num]();
801056b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056b7:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801056be:	ff d0                	call   *%eax
801056c0:	89 c2                	mov    %eax,%edx
801056c2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056c8:	8b 40 18             	mov    0x18(%eax),%eax
801056cb:	89 50 1c             	mov    %edx,0x1c(%eax)
801056ce:	eb 35                	jmp    80105705 <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
801056d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056d6:	8d 50 6c             	lea    0x6c(%eax),%edx
801056d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
    cprintf("%d %s: unknown sys call %d\n",
801056df:	8b 40 10             	mov    0x10(%eax),%eax
801056e2:	ff 75 f4             	push   -0xc(%ebp)
801056e5:	52                   	push   %edx
801056e6:	50                   	push   %eax
801056e7:	68 a7 89 10 80       	push   $0x801089a7
801056ec:	e8 d3 ac ff ff       	call   801003c4 <cprintf>
801056f1:	83 c4 10             	add    $0x10,%esp
    proc->tf->eax = -1;
801056f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056fa:	8b 40 18             	mov    0x18(%eax),%eax
801056fd:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105704:	90                   	nop
80105705:	90                   	nop
80105706:	c9                   	leave
80105707:	c3                   	ret

80105708 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105708:	55                   	push   %ebp
80105709:	89 e5                	mov    %esp,%ebp
8010570b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010570e:	83 ec 08             	sub    $0x8,%esp
80105711:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105714:	50                   	push   %eax
80105715:	ff 75 08             	push   0x8(%ebp)
80105718:	e8 b0 fe ff ff       	call   801055cd <argint>
8010571d:	83 c4 10             	add    $0x10,%esp
80105720:	85 c0                	test   %eax,%eax
80105722:	79 07                	jns    8010572b <argfd+0x23>
    return -1;
80105724:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105729:	eb 50                	jmp    8010577b <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
8010572b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010572e:	85 c0                	test   %eax,%eax
80105730:	78 21                	js     80105753 <argfd+0x4b>
80105732:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105735:	83 f8 0f             	cmp    $0xf,%eax
80105738:	7f 19                	jg     80105753 <argfd+0x4b>
8010573a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105740:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105743:	83 c2 08             	add    $0x8,%edx
80105746:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010574a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010574d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105751:	75 07                	jne    8010575a <argfd+0x52>
    return -1;
80105753:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105758:	eb 21                	jmp    8010577b <argfd+0x73>
  if(pfd)
8010575a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010575e:	74 08                	je     80105768 <argfd+0x60>
    *pfd = fd;
80105760:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105763:	8b 45 0c             	mov    0xc(%ebp),%eax
80105766:	89 10                	mov    %edx,(%eax)
  if(pf)
80105768:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010576c:	74 08                	je     80105776 <argfd+0x6e>
    *pf = f;
8010576e:	8b 45 10             	mov    0x10(%ebp),%eax
80105771:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105774:	89 10                	mov    %edx,(%eax)
  return 0;
80105776:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010577b:	c9                   	leave
8010577c:	c3                   	ret

8010577d <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010577d:	55                   	push   %ebp
8010577e:	89 e5                	mov    %esp,%ebp
80105780:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105783:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010578a:	eb 30                	jmp    801057bc <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
8010578c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105792:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105795:	83 c2 08             	add    $0x8,%edx
80105798:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010579c:	85 c0                	test   %eax,%eax
8010579e:	75 18                	jne    801057b8 <fdalloc+0x3b>
      proc->ofile[fd] = f;
801057a0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057a6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057a9:	8d 4a 08             	lea    0x8(%edx),%ecx
801057ac:	8b 55 08             	mov    0x8(%ebp),%edx
801057af:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801057b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057b6:	eb 0f                	jmp    801057c7 <fdalloc+0x4a>
  for(fd = 0; fd < NOFILE; fd++){
801057b8:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057bc:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
801057c0:	7e ca                	jle    8010578c <fdalloc+0xf>
    }
  }
  return -1;
801057c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801057c7:	c9                   	leave
801057c8:	c3                   	ret

801057c9 <sys_dup>:

int
sys_dup(void)
{
801057c9:	55                   	push   %ebp
801057ca:	89 e5                	mov    %esp,%ebp
801057cc:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
801057cf:	83 ec 04             	sub    $0x4,%esp
801057d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057d5:	50                   	push   %eax
801057d6:	6a 00                	push   $0x0
801057d8:	6a 00                	push   $0x0
801057da:	e8 29 ff ff ff       	call   80105708 <argfd>
801057df:	83 c4 10             	add    $0x10,%esp
801057e2:	85 c0                	test   %eax,%eax
801057e4:	79 07                	jns    801057ed <sys_dup+0x24>
    return -1;
801057e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057eb:	eb 31                	jmp    8010581e <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801057ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f0:	83 ec 0c             	sub    $0xc,%esp
801057f3:	50                   	push   %eax
801057f4:	e8 84 ff ff ff       	call   8010577d <fdalloc>
801057f9:	83 c4 10             	add    $0x10,%esp
801057fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801057ff:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105803:	79 07                	jns    8010580c <sys_dup+0x43>
    return -1;
80105805:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010580a:	eb 12                	jmp    8010581e <sys_dup+0x55>
  filedup(f);
8010580c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010580f:	83 ec 0c             	sub    $0xc,%esp
80105812:	50                   	push   %eax
80105813:	e8 19 b8 ff ff       	call   80101031 <filedup>
80105818:	83 c4 10             	add    $0x10,%esp
  return fd;
8010581b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010581e:	c9                   	leave
8010581f:	c3                   	ret

80105820 <sys_read>:

int
sys_read(void)
{
80105820:	55                   	push   %ebp
80105821:	89 e5                	mov    %esp,%ebp
80105823:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105826:	83 ec 04             	sub    $0x4,%esp
80105829:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010582c:	50                   	push   %eax
8010582d:	6a 00                	push   $0x0
8010582f:	6a 00                	push   $0x0
80105831:	e8 d2 fe ff ff       	call   80105708 <argfd>
80105836:	83 c4 10             	add    $0x10,%esp
80105839:	85 c0                	test   %eax,%eax
8010583b:	78 2e                	js     8010586b <sys_read+0x4b>
8010583d:	83 ec 08             	sub    $0x8,%esp
80105840:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105843:	50                   	push   %eax
80105844:	6a 02                	push   $0x2
80105846:	e8 82 fd ff ff       	call   801055cd <argint>
8010584b:	83 c4 10             	add    $0x10,%esp
8010584e:	85 c0                	test   %eax,%eax
80105850:	78 19                	js     8010586b <sys_read+0x4b>
80105852:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105855:	83 ec 04             	sub    $0x4,%esp
80105858:	50                   	push   %eax
80105859:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010585c:	50                   	push   %eax
8010585d:	6a 01                	push   $0x1
8010585f:	e8 91 fd ff ff       	call   801055f5 <argptr>
80105864:	83 c4 10             	add    $0x10,%esp
80105867:	85 c0                	test   %eax,%eax
80105869:	79 07                	jns    80105872 <sys_read+0x52>
    return -1;
8010586b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105870:	eb 17                	jmp    80105889 <sys_read+0x69>
  return fileread(f, p, n);
80105872:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105875:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105878:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010587b:	83 ec 04             	sub    $0x4,%esp
8010587e:	51                   	push   %ecx
8010587f:	52                   	push   %edx
80105880:	50                   	push   %eax
80105881:	e8 3b b9 ff ff       	call   801011c1 <fileread>
80105886:	83 c4 10             	add    $0x10,%esp
}
80105889:	c9                   	leave
8010588a:	c3                   	ret

8010588b <sys_write>:

int
sys_write(void)
{
8010588b:	55                   	push   %ebp
8010588c:	89 e5                	mov    %esp,%ebp
8010588e:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105891:	83 ec 04             	sub    $0x4,%esp
80105894:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105897:	50                   	push   %eax
80105898:	6a 00                	push   $0x0
8010589a:	6a 00                	push   $0x0
8010589c:	e8 67 fe ff ff       	call   80105708 <argfd>
801058a1:	83 c4 10             	add    $0x10,%esp
801058a4:	85 c0                	test   %eax,%eax
801058a6:	78 2e                	js     801058d6 <sys_write+0x4b>
801058a8:	83 ec 08             	sub    $0x8,%esp
801058ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058ae:	50                   	push   %eax
801058af:	6a 02                	push   $0x2
801058b1:	e8 17 fd ff ff       	call   801055cd <argint>
801058b6:	83 c4 10             	add    $0x10,%esp
801058b9:	85 c0                	test   %eax,%eax
801058bb:	78 19                	js     801058d6 <sys_write+0x4b>
801058bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058c0:	83 ec 04             	sub    $0x4,%esp
801058c3:	50                   	push   %eax
801058c4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058c7:	50                   	push   %eax
801058c8:	6a 01                	push   $0x1
801058ca:	e8 26 fd ff ff       	call   801055f5 <argptr>
801058cf:	83 c4 10             	add    $0x10,%esp
801058d2:	85 c0                	test   %eax,%eax
801058d4:	79 07                	jns    801058dd <sys_write+0x52>
    return -1;
801058d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058db:	eb 17                	jmp    801058f4 <sys_write+0x69>
  return filewrite(f, p, n);
801058dd:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801058e0:	8b 55 ec             	mov    -0x14(%ebp),%edx
801058e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058e6:	83 ec 04             	sub    $0x4,%esp
801058e9:	51                   	push   %ecx
801058ea:	52                   	push   %edx
801058eb:	50                   	push   %eax
801058ec:	e8 88 b9 ff ff       	call   80101279 <filewrite>
801058f1:	83 c4 10             	add    $0x10,%esp
}
801058f4:	c9                   	leave
801058f5:	c3                   	ret

801058f6 <sys_close>:

int
sys_close(void)
{
801058f6:	55                   	push   %ebp
801058f7:	89 e5                	mov    %esp,%ebp
801058f9:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
801058fc:	83 ec 04             	sub    $0x4,%esp
801058ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105902:	50                   	push   %eax
80105903:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105906:	50                   	push   %eax
80105907:	6a 00                	push   $0x0
80105909:	e8 fa fd ff ff       	call   80105708 <argfd>
8010590e:	83 c4 10             	add    $0x10,%esp
80105911:	85 c0                	test   %eax,%eax
80105913:	79 07                	jns    8010591c <sys_close+0x26>
    return -1;
80105915:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010591a:	eb 28                	jmp    80105944 <sys_close+0x4e>
  proc->ofile[fd] = 0;
8010591c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105922:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105925:	83 c2 08             	add    $0x8,%edx
80105928:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010592f:	00 
  fileclose(f);
80105930:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105933:	83 ec 0c             	sub    $0xc,%esp
80105936:	50                   	push   %eax
80105937:	e8 46 b7 ff ff       	call   80101082 <fileclose>
8010593c:	83 c4 10             	add    $0x10,%esp
  return 0;
8010593f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105944:	c9                   	leave
80105945:	c3                   	ret

80105946 <sys_fstat>:

int
sys_fstat(void)
{
80105946:	55                   	push   %ebp
80105947:	89 e5                	mov    %esp,%ebp
80105949:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010594c:	83 ec 04             	sub    $0x4,%esp
8010594f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105952:	50                   	push   %eax
80105953:	6a 00                	push   $0x0
80105955:	6a 00                	push   $0x0
80105957:	e8 ac fd ff ff       	call   80105708 <argfd>
8010595c:	83 c4 10             	add    $0x10,%esp
8010595f:	85 c0                	test   %eax,%eax
80105961:	78 17                	js     8010597a <sys_fstat+0x34>
80105963:	83 ec 04             	sub    $0x4,%esp
80105966:	6a 14                	push   $0x14
80105968:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010596b:	50                   	push   %eax
8010596c:	6a 01                	push   $0x1
8010596e:	e8 82 fc ff ff       	call   801055f5 <argptr>
80105973:	83 c4 10             	add    $0x10,%esp
80105976:	85 c0                	test   %eax,%eax
80105978:	79 07                	jns    80105981 <sys_fstat+0x3b>
    return -1;
8010597a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010597f:	eb 13                	jmp    80105994 <sys_fstat+0x4e>
  return filestat(f, st);
80105981:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105984:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105987:	83 ec 08             	sub    $0x8,%esp
8010598a:	52                   	push   %edx
8010598b:	50                   	push   %eax
8010598c:	e8 d9 b7 ff ff       	call   8010116a <filestat>
80105991:	83 c4 10             	add    $0x10,%esp
}
80105994:	c9                   	leave
80105995:	c3                   	ret

80105996 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105996:	55                   	push   %ebp
80105997:	89 e5                	mov    %esp,%ebp
80105999:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010599c:	83 ec 08             	sub    $0x8,%esp
8010599f:	8d 45 d8             	lea    -0x28(%ebp),%eax
801059a2:	50                   	push   %eax
801059a3:	6a 00                	push   $0x0
801059a5:	e8 a8 fc ff ff       	call   80105652 <argstr>
801059aa:	83 c4 10             	add    $0x10,%esp
801059ad:	85 c0                	test   %eax,%eax
801059af:	78 15                	js     801059c6 <sys_link+0x30>
801059b1:	83 ec 08             	sub    $0x8,%esp
801059b4:	8d 45 dc             	lea    -0x24(%ebp),%eax
801059b7:	50                   	push   %eax
801059b8:	6a 01                	push   $0x1
801059ba:	e8 93 fc ff ff       	call   80105652 <argstr>
801059bf:	83 c4 10             	add    $0x10,%esp
801059c2:	85 c0                	test   %eax,%eax
801059c4:	79 0a                	jns    801059d0 <sys_link+0x3a>
    return -1;
801059c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059cb:	e9 68 01 00 00       	jmp    80105b38 <sys_link+0x1a2>

  begin_op();
801059d0:	e8 81 db ff ff       	call   80103556 <begin_op>
  if((ip = namei(old)) == 0){
801059d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
801059d8:	83 ec 0c             	sub    $0xc,%esp
801059db:	50                   	push   %eax
801059dc:	e8 59 cb ff ff       	call   8010253a <namei>
801059e1:	83 c4 10             	add    $0x10,%esp
801059e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801059eb:	75 0f                	jne    801059fc <sys_link+0x66>
    end_op();
801059ed:	e8 f0 db ff ff       	call   801035e2 <end_op>
    return -1;
801059f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059f7:	e9 3c 01 00 00       	jmp    80105b38 <sys_link+0x1a2>
  }

  ilock(ip);
801059fc:	83 ec 0c             	sub    $0xc,%esp
801059ff:	ff 75 f4             	push   -0xc(%ebp)
80105a02:	e8 82 bf ff ff       	call   80101989 <ilock>
80105a07:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a0d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105a11:	66 83 f8 01          	cmp    $0x1,%ax
80105a15:	75 1d                	jne    80105a34 <sys_link+0x9e>
    iunlockput(ip);
80105a17:	83 ec 0c             	sub    $0xc,%esp
80105a1a:	ff 75 f4             	push   -0xc(%ebp)
80105a1d:	e8 27 c2 ff ff       	call   80101c49 <iunlockput>
80105a22:	83 c4 10             	add    $0x10,%esp
    end_op();
80105a25:	e8 b8 db ff ff       	call   801035e2 <end_op>
    return -1;
80105a2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a2f:	e9 04 01 00 00       	jmp    80105b38 <sys_link+0x1a2>
  }

  ip->nlink++;
80105a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a37:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105a3b:	83 c0 01             	add    $0x1,%eax
80105a3e:	89 c2                	mov    %eax,%edx
80105a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a43:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105a47:	83 ec 0c             	sub    $0xc,%esp
80105a4a:	ff 75 f4             	push   -0xc(%ebp)
80105a4d:	e8 5d bd ff ff       	call   801017af <iupdate>
80105a52:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105a55:	83 ec 0c             	sub    $0xc,%esp
80105a58:	ff 75 f4             	push   -0xc(%ebp)
80105a5b:	e8 87 c0 ff ff       	call   80101ae7 <iunlock>
80105a60:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105a63:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105a66:	83 ec 08             	sub    $0x8,%esp
80105a69:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105a6c:	52                   	push   %edx
80105a6d:	50                   	push   %eax
80105a6e:	e8 e3 ca ff ff       	call   80102556 <nameiparent>
80105a73:	83 c4 10             	add    $0x10,%esp
80105a76:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105a79:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105a7d:	74 71                	je     80105af0 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105a7f:	83 ec 0c             	sub    $0xc,%esp
80105a82:	ff 75 f0             	push   -0x10(%ebp)
80105a85:	e8 ff be ff ff       	call   80101989 <ilock>
80105a8a:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105a8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a90:	8b 10                	mov    (%eax),%edx
80105a92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a95:	8b 00                	mov    (%eax),%eax
80105a97:	39 c2                	cmp    %eax,%edx
80105a99:	75 1d                	jne    80105ab8 <sys_link+0x122>
80105a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a9e:	8b 40 04             	mov    0x4(%eax),%eax
80105aa1:	83 ec 04             	sub    $0x4,%esp
80105aa4:	50                   	push   %eax
80105aa5:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105aa8:	50                   	push   %eax
80105aa9:	ff 75 f0             	push   -0x10(%ebp)
80105aac:	e8 f1 c7 ff ff       	call   801022a2 <dirlink>
80105ab1:	83 c4 10             	add    $0x10,%esp
80105ab4:	85 c0                	test   %eax,%eax
80105ab6:	79 10                	jns    80105ac8 <sys_link+0x132>
    iunlockput(dp);
80105ab8:	83 ec 0c             	sub    $0xc,%esp
80105abb:	ff 75 f0             	push   -0x10(%ebp)
80105abe:	e8 86 c1 ff ff       	call   80101c49 <iunlockput>
80105ac3:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105ac6:	eb 29                	jmp    80105af1 <sys_link+0x15b>
  }
  iunlockput(dp);
80105ac8:	83 ec 0c             	sub    $0xc,%esp
80105acb:	ff 75 f0             	push   -0x10(%ebp)
80105ace:	e8 76 c1 ff ff       	call   80101c49 <iunlockput>
80105ad3:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105ad6:	83 ec 0c             	sub    $0xc,%esp
80105ad9:	ff 75 f4             	push   -0xc(%ebp)
80105adc:	e8 78 c0 ff ff       	call   80101b59 <iput>
80105ae1:	83 c4 10             	add    $0x10,%esp

  end_op();
80105ae4:	e8 f9 da ff ff       	call   801035e2 <end_op>

  return 0;
80105ae9:	b8 00 00 00 00       	mov    $0x0,%eax
80105aee:	eb 48                	jmp    80105b38 <sys_link+0x1a2>
    goto bad;
80105af0:	90                   	nop

bad:
  ilock(ip);
80105af1:	83 ec 0c             	sub    $0xc,%esp
80105af4:	ff 75 f4             	push   -0xc(%ebp)
80105af7:	e8 8d be ff ff       	call   80101989 <ilock>
80105afc:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105aff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b02:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b06:	83 e8 01             	sub    $0x1,%eax
80105b09:	89 c2                	mov    %eax,%edx
80105b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b0e:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105b12:	83 ec 0c             	sub    $0xc,%esp
80105b15:	ff 75 f4             	push   -0xc(%ebp)
80105b18:	e8 92 bc ff ff       	call   801017af <iupdate>
80105b1d:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105b20:	83 ec 0c             	sub    $0xc,%esp
80105b23:	ff 75 f4             	push   -0xc(%ebp)
80105b26:	e8 1e c1 ff ff       	call   80101c49 <iunlockput>
80105b2b:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b2e:	e8 af da ff ff       	call   801035e2 <end_op>
  return -1;
80105b33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b38:	c9                   	leave
80105b39:	c3                   	ret

80105b3a <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105b3a:	55                   	push   %ebp
80105b3b:	89 e5                	mov    %esp,%ebp
80105b3d:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b40:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105b47:	eb 40                	jmp    80105b89 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b4c:	6a 10                	push   $0x10
80105b4e:	50                   	push   %eax
80105b4f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b52:	50                   	push   %eax
80105b53:	ff 75 08             	push   0x8(%ebp)
80105b56:	e8 97 c3 ff ff       	call   80101ef2 <readi>
80105b5b:	83 c4 10             	add    $0x10,%esp
80105b5e:	83 f8 10             	cmp    $0x10,%eax
80105b61:	74 0d                	je     80105b70 <isdirempty+0x36>
      panic("isdirempty: readi");
80105b63:	83 ec 0c             	sub    $0xc,%esp
80105b66:	68 c3 89 10 80       	push   $0x801089c3
80105b6b:	e8 09 aa ff ff       	call   80100579 <panic>
    if(de.inum != 0)
80105b70:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105b74:	66 85 c0             	test   %ax,%ax
80105b77:	74 07                	je     80105b80 <isdirempty+0x46>
      return 0;
80105b79:	b8 00 00 00 00       	mov    $0x0,%eax
80105b7e:	eb 1b                	jmp    80105b9b <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b83:	83 c0 10             	add    $0x10,%eax
80105b86:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b89:	8b 45 08             	mov    0x8(%ebp),%eax
80105b8c:	8b 40 18             	mov    0x18(%eax),%eax
80105b8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b92:	39 c2                	cmp    %eax,%edx
80105b94:	72 b3                	jb     80105b49 <isdirempty+0xf>
  }
  return 1;
80105b96:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105b9b:	c9                   	leave
80105b9c:	c3                   	ret

80105b9d <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105b9d:	55                   	push   %ebp
80105b9e:	89 e5                	mov    %esp,%ebp
80105ba0:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105ba3:	83 ec 08             	sub    $0x8,%esp
80105ba6:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105ba9:	50                   	push   %eax
80105baa:	6a 00                	push   $0x0
80105bac:	e8 a1 fa ff ff       	call   80105652 <argstr>
80105bb1:	83 c4 10             	add    $0x10,%esp
80105bb4:	85 c0                	test   %eax,%eax
80105bb6:	79 0a                	jns    80105bc2 <sys_unlink+0x25>
    return -1;
80105bb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bbd:	e9 bf 01 00 00       	jmp    80105d81 <sys_unlink+0x1e4>

  begin_op();
80105bc2:	e8 8f d9 ff ff       	call   80103556 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105bc7:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105bca:	83 ec 08             	sub    $0x8,%esp
80105bcd:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105bd0:	52                   	push   %edx
80105bd1:	50                   	push   %eax
80105bd2:	e8 7f c9 ff ff       	call   80102556 <nameiparent>
80105bd7:	83 c4 10             	add    $0x10,%esp
80105bda:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bdd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105be1:	75 0f                	jne    80105bf2 <sys_unlink+0x55>
    end_op();
80105be3:	e8 fa d9 ff ff       	call   801035e2 <end_op>
    return -1;
80105be8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bed:	e9 8f 01 00 00       	jmp    80105d81 <sys_unlink+0x1e4>
  }

  ilock(dp);
80105bf2:	83 ec 0c             	sub    $0xc,%esp
80105bf5:	ff 75 f4             	push   -0xc(%ebp)
80105bf8:	e8 8c bd ff ff       	call   80101989 <ilock>
80105bfd:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105c00:	83 ec 08             	sub    $0x8,%esp
80105c03:	68 d5 89 10 80       	push   $0x801089d5
80105c08:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c0b:	50                   	push   %eax
80105c0c:	e8 bc c5 ff ff       	call   801021cd <namecmp>
80105c11:	83 c4 10             	add    $0x10,%esp
80105c14:	85 c0                	test   %eax,%eax
80105c16:	0f 84 49 01 00 00    	je     80105d65 <sys_unlink+0x1c8>
80105c1c:	83 ec 08             	sub    $0x8,%esp
80105c1f:	68 d7 89 10 80       	push   $0x801089d7
80105c24:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c27:	50                   	push   %eax
80105c28:	e8 a0 c5 ff ff       	call   801021cd <namecmp>
80105c2d:	83 c4 10             	add    $0x10,%esp
80105c30:	85 c0                	test   %eax,%eax
80105c32:	0f 84 2d 01 00 00    	je     80105d65 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105c38:	83 ec 04             	sub    $0x4,%esp
80105c3b:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105c3e:	50                   	push   %eax
80105c3f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c42:	50                   	push   %eax
80105c43:	ff 75 f4             	push   -0xc(%ebp)
80105c46:	e8 9d c5 ff ff       	call   801021e8 <dirlookup>
80105c4b:	83 c4 10             	add    $0x10,%esp
80105c4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c51:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c55:	0f 84 0d 01 00 00    	je     80105d68 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105c5b:	83 ec 0c             	sub    $0xc,%esp
80105c5e:	ff 75 f0             	push   -0x10(%ebp)
80105c61:	e8 23 bd ff ff       	call   80101989 <ilock>
80105c66:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105c69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c6c:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c70:	66 85 c0             	test   %ax,%ax
80105c73:	7f 0d                	jg     80105c82 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105c75:	83 ec 0c             	sub    $0xc,%esp
80105c78:	68 da 89 10 80       	push   $0x801089da
80105c7d:	e8 f7 a8 ff ff       	call   80100579 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105c82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c85:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105c89:	66 83 f8 01          	cmp    $0x1,%ax
80105c8d:	75 25                	jne    80105cb4 <sys_unlink+0x117>
80105c8f:	83 ec 0c             	sub    $0xc,%esp
80105c92:	ff 75 f0             	push   -0x10(%ebp)
80105c95:	e8 a0 fe ff ff       	call   80105b3a <isdirempty>
80105c9a:	83 c4 10             	add    $0x10,%esp
80105c9d:	85 c0                	test   %eax,%eax
80105c9f:	75 13                	jne    80105cb4 <sys_unlink+0x117>
    iunlockput(ip);
80105ca1:	83 ec 0c             	sub    $0xc,%esp
80105ca4:	ff 75 f0             	push   -0x10(%ebp)
80105ca7:	e8 9d bf ff ff       	call   80101c49 <iunlockput>
80105cac:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105caf:	e9 b5 00 00 00       	jmp    80105d69 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105cb4:	83 ec 04             	sub    $0x4,%esp
80105cb7:	6a 10                	push   $0x10
80105cb9:	6a 00                	push   $0x0
80105cbb:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105cbe:	50                   	push   %eax
80105cbf:	e8 e5 f5 ff ff       	call   801052a9 <memset>
80105cc4:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105cc7:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105cca:	6a 10                	push   $0x10
80105ccc:	50                   	push   %eax
80105ccd:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105cd0:	50                   	push   %eax
80105cd1:	ff 75 f4             	push   -0xc(%ebp)
80105cd4:	e8 6e c3 ff ff       	call   80102047 <writei>
80105cd9:	83 c4 10             	add    $0x10,%esp
80105cdc:	83 f8 10             	cmp    $0x10,%eax
80105cdf:	74 0d                	je     80105cee <sys_unlink+0x151>
    panic("unlink: writei");
80105ce1:	83 ec 0c             	sub    $0xc,%esp
80105ce4:	68 ec 89 10 80       	push   $0x801089ec
80105ce9:	e8 8b a8 ff ff       	call   80100579 <panic>
  if(ip->type == T_DIR){
80105cee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cf1:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105cf5:	66 83 f8 01          	cmp    $0x1,%ax
80105cf9:	75 21                	jne    80105d1c <sys_unlink+0x17f>
    dp->nlink--;
80105cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cfe:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d02:	83 e8 01             	sub    $0x1,%eax
80105d05:	89 c2                	mov    %eax,%edx
80105d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d0a:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105d0e:	83 ec 0c             	sub    $0xc,%esp
80105d11:	ff 75 f4             	push   -0xc(%ebp)
80105d14:	e8 96 ba ff ff       	call   801017af <iupdate>
80105d19:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105d1c:	83 ec 0c             	sub    $0xc,%esp
80105d1f:	ff 75 f4             	push   -0xc(%ebp)
80105d22:	e8 22 bf ff ff       	call   80101c49 <iunlockput>
80105d27:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105d2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d2d:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d31:	83 e8 01             	sub    $0x1,%eax
80105d34:	89 c2                	mov    %eax,%edx
80105d36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d39:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105d3d:	83 ec 0c             	sub    $0xc,%esp
80105d40:	ff 75 f0             	push   -0x10(%ebp)
80105d43:	e8 67 ba ff ff       	call   801017af <iupdate>
80105d48:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105d4b:	83 ec 0c             	sub    $0xc,%esp
80105d4e:	ff 75 f0             	push   -0x10(%ebp)
80105d51:	e8 f3 be ff ff       	call   80101c49 <iunlockput>
80105d56:	83 c4 10             	add    $0x10,%esp

  end_op();
80105d59:	e8 84 d8 ff ff       	call   801035e2 <end_op>

  return 0;
80105d5e:	b8 00 00 00 00       	mov    $0x0,%eax
80105d63:	eb 1c                	jmp    80105d81 <sys_unlink+0x1e4>
    goto bad;
80105d65:	90                   	nop
80105d66:	eb 01                	jmp    80105d69 <sys_unlink+0x1cc>
    goto bad;
80105d68:	90                   	nop

bad:
  iunlockput(dp);
80105d69:	83 ec 0c             	sub    $0xc,%esp
80105d6c:	ff 75 f4             	push   -0xc(%ebp)
80105d6f:	e8 d5 be ff ff       	call   80101c49 <iunlockput>
80105d74:	83 c4 10             	add    $0x10,%esp
  end_op();
80105d77:	e8 66 d8 ff ff       	call   801035e2 <end_op>
  return -1;
80105d7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d81:	c9                   	leave
80105d82:	c3                   	ret

80105d83 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105d83:	55                   	push   %ebp
80105d84:	89 e5                	mov    %esp,%ebp
80105d86:	83 ec 38             	sub    $0x38,%esp
80105d89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105d8c:	8b 55 10             	mov    0x10(%ebp),%edx
80105d8f:	8b 45 14             	mov    0x14(%ebp),%eax
80105d92:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105d96:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105d9a:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105d9e:	83 ec 08             	sub    $0x8,%esp
80105da1:	8d 45 de             	lea    -0x22(%ebp),%eax
80105da4:	50                   	push   %eax
80105da5:	ff 75 08             	push   0x8(%ebp)
80105da8:	e8 a9 c7 ff ff       	call   80102556 <nameiparent>
80105dad:	83 c4 10             	add    $0x10,%esp
80105db0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105db3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105db7:	75 0a                	jne    80105dc3 <create+0x40>
    return 0;
80105db9:	b8 00 00 00 00       	mov    $0x0,%eax
80105dbe:	e9 90 01 00 00       	jmp    80105f53 <create+0x1d0>
  ilock(dp);
80105dc3:	83 ec 0c             	sub    $0xc,%esp
80105dc6:	ff 75 f4             	push   -0xc(%ebp)
80105dc9:	e8 bb bb ff ff       	call   80101989 <ilock>
80105dce:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105dd1:	83 ec 04             	sub    $0x4,%esp
80105dd4:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105dd7:	50                   	push   %eax
80105dd8:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ddb:	50                   	push   %eax
80105ddc:	ff 75 f4             	push   -0xc(%ebp)
80105ddf:	e8 04 c4 ff ff       	call   801021e8 <dirlookup>
80105de4:	83 c4 10             	add    $0x10,%esp
80105de7:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105dea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105dee:	74 50                	je     80105e40 <create+0xbd>
    iunlockput(dp);
80105df0:	83 ec 0c             	sub    $0xc,%esp
80105df3:	ff 75 f4             	push   -0xc(%ebp)
80105df6:	e8 4e be ff ff       	call   80101c49 <iunlockput>
80105dfb:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105dfe:	83 ec 0c             	sub    $0xc,%esp
80105e01:	ff 75 f0             	push   -0x10(%ebp)
80105e04:	e8 80 bb ff ff       	call   80101989 <ilock>
80105e09:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105e0c:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105e11:	75 15                	jne    80105e28 <create+0xa5>
80105e13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e16:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e1a:	66 83 f8 02          	cmp    $0x2,%ax
80105e1e:	75 08                	jne    80105e28 <create+0xa5>
      return ip;
80105e20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e23:	e9 2b 01 00 00       	jmp    80105f53 <create+0x1d0>
    iunlockput(ip);
80105e28:	83 ec 0c             	sub    $0xc,%esp
80105e2b:	ff 75 f0             	push   -0x10(%ebp)
80105e2e:	e8 16 be ff ff       	call   80101c49 <iunlockput>
80105e33:	83 c4 10             	add    $0x10,%esp
    return 0;
80105e36:	b8 00 00 00 00       	mov    $0x0,%eax
80105e3b:	e9 13 01 00 00       	jmp    80105f53 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105e40:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e47:	8b 00                	mov    (%eax),%eax
80105e49:	83 ec 08             	sub    $0x8,%esp
80105e4c:	52                   	push   %edx
80105e4d:	50                   	push   %eax
80105e4e:	e8 86 b8 ff ff       	call   801016d9 <ialloc>
80105e53:	83 c4 10             	add    $0x10,%esp
80105e56:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e59:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e5d:	75 0d                	jne    80105e6c <create+0xe9>
    panic("create: ialloc");
80105e5f:	83 ec 0c             	sub    $0xc,%esp
80105e62:	68 fb 89 10 80       	push   $0x801089fb
80105e67:	e8 0d a7 ff ff       	call   80100579 <panic>

  ilock(ip);
80105e6c:	83 ec 0c             	sub    $0xc,%esp
80105e6f:	ff 75 f0             	push   -0x10(%ebp)
80105e72:	e8 12 bb ff ff       	call   80101989 <ilock>
80105e77:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105e7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e7d:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105e81:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105e85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e88:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105e8c:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105e90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e93:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105e99:	83 ec 0c             	sub    $0xc,%esp
80105e9c:	ff 75 f0             	push   -0x10(%ebp)
80105e9f:	e8 0b b9 ff ff       	call   801017af <iupdate>
80105ea4:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105ea7:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105eac:	75 6a                	jne    80105f18 <create+0x195>
    dp->nlink++;  // for ".."
80105eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb1:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105eb5:	83 c0 01             	add    $0x1,%eax
80105eb8:	89 c2                	mov    %eax,%edx
80105eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ebd:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105ec1:	83 ec 0c             	sub    $0xc,%esp
80105ec4:	ff 75 f4             	push   -0xc(%ebp)
80105ec7:	e8 e3 b8 ff ff       	call   801017af <iupdate>
80105ecc:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105ecf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ed2:	8b 40 04             	mov    0x4(%eax),%eax
80105ed5:	83 ec 04             	sub    $0x4,%esp
80105ed8:	50                   	push   %eax
80105ed9:	68 d5 89 10 80       	push   $0x801089d5
80105ede:	ff 75 f0             	push   -0x10(%ebp)
80105ee1:	e8 bc c3 ff ff       	call   801022a2 <dirlink>
80105ee6:	83 c4 10             	add    $0x10,%esp
80105ee9:	85 c0                	test   %eax,%eax
80105eeb:	78 1e                	js     80105f0b <create+0x188>
80105eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef0:	8b 40 04             	mov    0x4(%eax),%eax
80105ef3:	83 ec 04             	sub    $0x4,%esp
80105ef6:	50                   	push   %eax
80105ef7:	68 d7 89 10 80       	push   $0x801089d7
80105efc:	ff 75 f0             	push   -0x10(%ebp)
80105eff:	e8 9e c3 ff ff       	call   801022a2 <dirlink>
80105f04:	83 c4 10             	add    $0x10,%esp
80105f07:	85 c0                	test   %eax,%eax
80105f09:	79 0d                	jns    80105f18 <create+0x195>
      panic("create dots");
80105f0b:	83 ec 0c             	sub    $0xc,%esp
80105f0e:	68 0a 8a 10 80       	push   $0x80108a0a
80105f13:	e8 61 a6 ff ff       	call   80100579 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105f18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f1b:	8b 40 04             	mov    0x4(%eax),%eax
80105f1e:	83 ec 04             	sub    $0x4,%esp
80105f21:	50                   	push   %eax
80105f22:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f25:	50                   	push   %eax
80105f26:	ff 75 f4             	push   -0xc(%ebp)
80105f29:	e8 74 c3 ff ff       	call   801022a2 <dirlink>
80105f2e:	83 c4 10             	add    $0x10,%esp
80105f31:	85 c0                	test   %eax,%eax
80105f33:	79 0d                	jns    80105f42 <create+0x1bf>
    panic("create: dirlink");
80105f35:	83 ec 0c             	sub    $0xc,%esp
80105f38:	68 16 8a 10 80       	push   $0x80108a16
80105f3d:	e8 37 a6 ff ff       	call   80100579 <panic>

  iunlockput(dp);
80105f42:	83 ec 0c             	sub    $0xc,%esp
80105f45:	ff 75 f4             	push   -0xc(%ebp)
80105f48:	e8 fc bc ff ff       	call   80101c49 <iunlockput>
80105f4d:	83 c4 10             	add    $0x10,%esp

  return ip;
80105f50:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105f53:	c9                   	leave
80105f54:	c3                   	ret

80105f55 <sys_open>:

int
sys_open(void)
{
80105f55:	55                   	push   %ebp
80105f56:	89 e5                	mov    %esp,%ebp
80105f58:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105f5b:	83 ec 08             	sub    $0x8,%esp
80105f5e:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105f61:	50                   	push   %eax
80105f62:	6a 00                	push   $0x0
80105f64:	e8 e9 f6 ff ff       	call   80105652 <argstr>
80105f69:	83 c4 10             	add    $0x10,%esp
80105f6c:	85 c0                	test   %eax,%eax
80105f6e:	78 15                	js     80105f85 <sys_open+0x30>
80105f70:	83 ec 08             	sub    $0x8,%esp
80105f73:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105f76:	50                   	push   %eax
80105f77:	6a 01                	push   $0x1
80105f79:	e8 4f f6 ff ff       	call   801055cd <argint>
80105f7e:	83 c4 10             	add    $0x10,%esp
80105f81:	85 c0                	test   %eax,%eax
80105f83:	79 0a                	jns    80105f8f <sys_open+0x3a>
    return -1;
80105f85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f8a:	e9 61 01 00 00       	jmp    801060f0 <sys_open+0x19b>

  begin_op();
80105f8f:	e8 c2 d5 ff ff       	call   80103556 <begin_op>

  if(omode & O_CREATE){
80105f94:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f97:	25 00 02 00 00       	and    $0x200,%eax
80105f9c:	85 c0                	test   %eax,%eax
80105f9e:	74 2a                	je     80105fca <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105fa0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fa3:	6a 00                	push   $0x0
80105fa5:	6a 00                	push   $0x0
80105fa7:	6a 02                	push   $0x2
80105fa9:	50                   	push   %eax
80105faa:	e8 d4 fd ff ff       	call   80105d83 <create>
80105faf:	83 c4 10             	add    $0x10,%esp
80105fb2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105fb5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fb9:	75 75                	jne    80106030 <sys_open+0xdb>
      end_op();
80105fbb:	e8 22 d6 ff ff       	call   801035e2 <end_op>
      return -1;
80105fc0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fc5:	e9 26 01 00 00       	jmp    801060f0 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
80105fca:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fcd:	83 ec 0c             	sub    $0xc,%esp
80105fd0:	50                   	push   %eax
80105fd1:	e8 64 c5 ff ff       	call   8010253a <namei>
80105fd6:	83 c4 10             	add    $0x10,%esp
80105fd9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fdc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105fe0:	75 0f                	jne    80105ff1 <sys_open+0x9c>
      end_op();
80105fe2:	e8 fb d5 ff ff       	call   801035e2 <end_op>
      return -1;
80105fe7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fec:	e9 ff 00 00 00       	jmp    801060f0 <sys_open+0x19b>
    }
    ilock(ip);
80105ff1:	83 ec 0c             	sub    $0xc,%esp
80105ff4:	ff 75 f4             	push   -0xc(%ebp)
80105ff7:	e8 8d b9 ff ff       	call   80101989 <ilock>
80105ffc:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80105fff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106002:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106006:	66 83 f8 01          	cmp    $0x1,%ax
8010600a:	75 24                	jne    80106030 <sys_open+0xdb>
8010600c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010600f:	85 c0                	test   %eax,%eax
80106011:	74 1d                	je     80106030 <sys_open+0xdb>
      iunlockput(ip);
80106013:	83 ec 0c             	sub    $0xc,%esp
80106016:	ff 75 f4             	push   -0xc(%ebp)
80106019:	e8 2b bc ff ff       	call   80101c49 <iunlockput>
8010601e:	83 c4 10             	add    $0x10,%esp
      end_op();
80106021:	e8 bc d5 ff ff       	call   801035e2 <end_op>
      return -1;
80106026:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010602b:	e9 c0 00 00 00       	jmp    801060f0 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106030:	e8 8f af ff ff       	call   80100fc4 <filealloc>
80106035:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106038:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010603c:	74 17                	je     80106055 <sys_open+0x100>
8010603e:	83 ec 0c             	sub    $0xc,%esp
80106041:	ff 75 f0             	push   -0x10(%ebp)
80106044:	e8 34 f7 ff ff       	call   8010577d <fdalloc>
80106049:	83 c4 10             	add    $0x10,%esp
8010604c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010604f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106053:	79 2e                	jns    80106083 <sys_open+0x12e>
    if(f)
80106055:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106059:	74 0e                	je     80106069 <sys_open+0x114>
      fileclose(f);
8010605b:	83 ec 0c             	sub    $0xc,%esp
8010605e:	ff 75 f0             	push   -0x10(%ebp)
80106061:	e8 1c b0 ff ff       	call   80101082 <fileclose>
80106066:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80106069:	83 ec 0c             	sub    $0xc,%esp
8010606c:	ff 75 f4             	push   -0xc(%ebp)
8010606f:	e8 d5 bb ff ff       	call   80101c49 <iunlockput>
80106074:	83 c4 10             	add    $0x10,%esp
    end_op();
80106077:	e8 66 d5 ff ff       	call   801035e2 <end_op>
    return -1;
8010607c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106081:	eb 6d                	jmp    801060f0 <sys_open+0x19b>
  }
  iunlock(ip);
80106083:	83 ec 0c             	sub    $0xc,%esp
80106086:	ff 75 f4             	push   -0xc(%ebp)
80106089:	e8 59 ba ff ff       	call   80101ae7 <iunlock>
8010608e:	83 c4 10             	add    $0x10,%esp
  end_op();
80106091:	e8 4c d5 ff ff       	call   801035e2 <end_op>

  f->type = FD_INODE;
80106096:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106099:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010609f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060a5:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801060a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ab:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801060b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060b5:	83 e0 01             	and    $0x1,%eax
801060b8:	85 c0                	test   %eax,%eax
801060ba:	0f 94 c0             	sete   %al
801060bd:	89 c2                	mov    %eax,%edx
801060bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c2:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801060c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060c8:	83 e0 01             	and    $0x1,%eax
801060cb:	85 c0                	test   %eax,%eax
801060cd:	75 0a                	jne    801060d9 <sys_open+0x184>
801060cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060d2:	83 e0 02             	and    $0x2,%eax
801060d5:	85 c0                	test   %eax,%eax
801060d7:	74 07                	je     801060e0 <sys_open+0x18b>
801060d9:	b8 01 00 00 00       	mov    $0x1,%eax
801060de:	eb 05                	jmp    801060e5 <sys_open+0x190>
801060e0:	b8 00 00 00 00       	mov    $0x0,%eax
801060e5:	89 c2                	mov    %eax,%edx
801060e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ea:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801060ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801060f0:	c9                   	leave
801060f1:	c3                   	ret

801060f2 <sys_mkdir>:

int
sys_mkdir(void)
{
801060f2:	55                   	push   %ebp
801060f3:	89 e5                	mov    %esp,%ebp
801060f5:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801060f8:	e8 59 d4 ff ff       	call   80103556 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801060fd:	83 ec 08             	sub    $0x8,%esp
80106100:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106103:	50                   	push   %eax
80106104:	6a 00                	push   $0x0
80106106:	e8 47 f5 ff ff       	call   80105652 <argstr>
8010610b:	83 c4 10             	add    $0x10,%esp
8010610e:	85 c0                	test   %eax,%eax
80106110:	78 1b                	js     8010612d <sys_mkdir+0x3b>
80106112:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106115:	6a 00                	push   $0x0
80106117:	6a 00                	push   $0x0
80106119:	6a 01                	push   $0x1
8010611b:	50                   	push   %eax
8010611c:	e8 62 fc ff ff       	call   80105d83 <create>
80106121:	83 c4 10             	add    $0x10,%esp
80106124:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106127:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010612b:	75 0c                	jne    80106139 <sys_mkdir+0x47>
    end_op();
8010612d:	e8 b0 d4 ff ff       	call   801035e2 <end_op>
    return -1;
80106132:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106137:	eb 18                	jmp    80106151 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106139:	83 ec 0c             	sub    $0xc,%esp
8010613c:	ff 75 f4             	push   -0xc(%ebp)
8010613f:	e8 05 bb ff ff       	call   80101c49 <iunlockput>
80106144:	83 c4 10             	add    $0x10,%esp
  end_op();
80106147:	e8 96 d4 ff ff       	call   801035e2 <end_op>
  return 0;
8010614c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106151:	c9                   	leave
80106152:	c3                   	ret

80106153 <sys_mknod>:

int
sys_mknod(void)
{
80106153:	55                   	push   %ebp
80106154:	89 e5                	mov    %esp,%ebp
80106156:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
80106159:	e8 f8 d3 ff ff       	call   80103556 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
8010615e:	83 ec 08             	sub    $0x8,%esp
80106161:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106164:	50                   	push   %eax
80106165:	6a 00                	push   $0x0
80106167:	e8 e6 f4 ff ff       	call   80105652 <argstr>
8010616c:	83 c4 10             	add    $0x10,%esp
8010616f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106172:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106176:	78 4f                	js     801061c7 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
80106178:	83 ec 08             	sub    $0x8,%esp
8010617b:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010617e:	50                   	push   %eax
8010617f:	6a 01                	push   $0x1
80106181:	e8 47 f4 ff ff       	call   801055cd <argint>
80106186:	83 c4 10             	add    $0x10,%esp
  if((len=argstr(0, &path)) < 0 ||
80106189:	85 c0                	test   %eax,%eax
8010618b:	78 3a                	js     801061c7 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
8010618d:	83 ec 08             	sub    $0x8,%esp
80106190:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106193:	50                   	push   %eax
80106194:	6a 02                	push   $0x2
80106196:	e8 32 f4 ff ff       	call   801055cd <argint>
8010619b:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
8010619e:	85 c0                	test   %eax,%eax
801061a0:	78 25                	js     801061c7 <sys_mknod+0x74>
     (ip = create(path, T_DEV, major, minor)) == 0){
801061a2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061a5:	0f bf c8             	movswl %ax,%ecx
801061a8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061ab:	0f bf d0             	movswl %ax,%edx
801061ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061b1:	51                   	push   %ecx
801061b2:	52                   	push   %edx
801061b3:	6a 03                	push   $0x3
801061b5:	50                   	push   %eax
801061b6:	e8 c8 fb ff ff       	call   80105d83 <create>
801061bb:	83 c4 10             	add    $0x10,%esp
801061be:	89 45 f0             	mov    %eax,-0x10(%ebp)
     argint(2, &minor) < 0 ||
801061c1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061c5:	75 0c                	jne    801061d3 <sys_mknod+0x80>
    end_op();
801061c7:	e8 16 d4 ff ff       	call   801035e2 <end_op>
    return -1;
801061cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061d1:	eb 18                	jmp    801061eb <sys_mknod+0x98>
  }
  iunlockput(ip);
801061d3:	83 ec 0c             	sub    $0xc,%esp
801061d6:	ff 75 f0             	push   -0x10(%ebp)
801061d9:	e8 6b ba ff ff       	call   80101c49 <iunlockput>
801061de:	83 c4 10             	add    $0x10,%esp
  end_op();
801061e1:	e8 fc d3 ff ff       	call   801035e2 <end_op>
  return 0;
801061e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061eb:	c9                   	leave
801061ec:	c3                   	ret

801061ed <sys_chdir>:

int
sys_chdir(void)
{
801061ed:	55                   	push   %ebp
801061ee:	89 e5                	mov    %esp,%ebp
801061f0:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801061f3:	e8 5e d3 ff ff       	call   80103556 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801061f8:	83 ec 08             	sub    $0x8,%esp
801061fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061fe:	50                   	push   %eax
801061ff:	6a 00                	push   $0x0
80106201:	e8 4c f4 ff ff       	call   80105652 <argstr>
80106206:	83 c4 10             	add    $0x10,%esp
80106209:	85 c0                	test   %eax,%eax
8010620b:	78 18                	js     80106225 <sys_chdir+0x38>
8010620d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106210:	83 ec 0c             	sub    $0xc,%esp
80106213:	50                   	push   %eax
80106214:	e8 21 c3 ff ff       	call   8010253a <namei>
80106219:	83 c4 10             	add    $0x10,%esp
8010621c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010621f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106223:	75 0c                	jne    80106231 <sys_chdir+0x44>
    end_op();
80106225:	e8 b8 d3 ff ff       	call   801035e2 <end_op>
    return -1;
8010622a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010622f:	eb 6e                	jmp    8010629f <sys_chdir+0xb2>
  }
  ilock(ip);
80106231:	83 ec 0c             	sub    $0xc,%esp
80106234:	ff 75 f4             	push   -0xc(%ebp)
80106237:	e8 4d b7 ff ff       	call   80101989 <ilock>
8010623c:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
8010623f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106242:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106246:	66 83 f8 01          	cmp    $0x1,%ax
8010624a:	74 1a                	je     80106266 <sys_chdir+0x79>
    iunlockput(ip);
8010624c:	83 ec 0c             	sub    $0xc,%esp
8010624f:	ff 75 f4             	push   -0xc(%ebp)
80106252:	e8 f2 b9 ff ff       	call   80101c49 <iunlockput>
80106257:	83 c4 10             	add    $0x10,%esp
    end_op();
8010625a:	e8 83 d3 ff ff       	call   801035e2 <end_op>
    return -1;
8010625f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106264:	eb 39                	jmp    8010629f <sys_chdir+0xb2>
  }
  iunlock(ip);
80106266:	83 ec 0c             	sub    $0xc,%esp
80106269:	ff 75 f4             	push   -0xc(%ebp)
8010626c:	e8 76 b8 ff ff       	call   80101ae7 <iunlock>
80106271:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
80106274:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010627a:	8b 40 68             	mov    0x68(%eax),%eax
8010627d:	83 ec 0c             	sub    $0xc,%esp
80106280:	50                   	push   %eax
80106281:	e8 d3 b8 ff ff       	call   80101b59 <iput>
80106286:	83 c4 10             	add    $0x10,%esp
  end_op();
80106289:	e8 54 d3 ff ff       	call   801035e2 <end_op>
  proc->cwd = ip;
8010628e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106294:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106297:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010629a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010629f:	c9                   	leave
801062a0:	c3                   	ret

801062a1 <sys_exec>:

int
sys_exec(void)
{
801062a1:	55                   	push   %ebp
801062a2:	89 e5                	mov    %esp,%ebp
801062a4:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801062aa:	83 ec 08             	sub    $0x8,%esp
801062ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062b0:	50                   	push   %eax
801062b1:	6a 00                	push   $0x0
801062b3:	e8 9a f3 ff ff       	call   80105652 <argstr>
801062b8:	83 c4 10             	add    $0x10,%esp
801062bb:	85 c0                	test   %eax,%eax
801062bd:	78 18                	js     801062d7 <sys_exec+0x36>
801062bf:	83 ec 08             	sub    $0x8,%esp
801062c2:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801062c8:	50                   	push   %eax
801062c9:	6a 01                	push   $0x1
801062cb:	e8 fd f2 ff ff       	call   801055cd <argint>
801062d0:	83 c4 10             	add    $0x10,%esp
801062d3:	85 c0                	test   %eax,%eax
801062d5:	79 0a                	jns    801062e1 <sys_exec+0x40>
    return -1;
801062d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062dc:	e9 c6 00 00 00       	jmp    801063a7 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
801062e1:	83 ec 04             	sub    $0x4,%esp
801062e4:	68 80 00 00 00       	push   $0x80
801062e9:	6a 00                	push   $0x0
801062eb:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801062f1:	50                   	push   %eax
801062f2:	e8 b2 ef ff ff       	call   801052a9 <memset>
801062f7:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801062fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106301:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106304:	83 f8 1f             	cmp    $0x1f,%eax
80106307:	76 0a                	jbe    80106313 <sys_exec+0x72>
      return -1;
80106309:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010630e:	e9 94 00 00 00       	jmp    801063a7 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106313:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106316:	c1 e0 02             	shl    $0x2,%eax
80106319:	89 c2                	mov    %eax,%edx
8010631b:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106321:	01 c2                	add    %eax,%edx
80106323:	83 ec 08             	sub    $0x8,%esp
80106326:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010632c:	50                   	push   %eax
8010632d:	52                   	push   %edx
8010632e:	e8 00 f2 ff ff       	call   80105533 <fetchint>
80106333:	83 c4 10             	add    $0x10,%esp
80106336:	85 c0                	test   %eax,%eax
80106338:	79 07                	jns    80106341 <sys_exec+0xa0>
      return -1;
8010633a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010633f:	eb 66                	jmp    801063a7 <sys_exec+0x106>
    if(uarg == 0){
80106341:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106347:	85 c0                	test   %eax,%eax
80106349:	75 27                	jne    80106372 <sys_exec+0xd1>
      argv[i] = 0;
8010634b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010634e:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106355:	00 00 00 00 
      break;
80106359:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010635a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010635d:	83 ec 08             	sub    $0x8,%esp
80106360:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106366:	52                   	push   %edx
80106367:	50                   	push   %eax
80106368:	e8 35 a8 ff ff       	call   80100ba2 <exec>
8010636d:	83 c4 10             	add    $0x10,%esp
80106370:	eb 35                	jmp    801063a7 <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80106372:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106378:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010637b:	c1 e2 02             	shl    $0x2,%edx
8010637e:	01 c2                	add    %eax,%edx
80106380:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106386:	83 ec 08             	sub    $0x8,%esp
80106389:	52                   	push   %edx
8010638a:	50                   	push   %eax
8010638b:	e8 dd f1 ff ff       	call   8010556d <fetchstr>
80106390:	83 c4 10             	add    $0x10,%esp
80106393:	85 c0                	test   %eax,%eax
80106395:	79 07                	jns    8010639e <sys_exec+0xfd>
      return -1;
80106397:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010639c:	eb 09                	jmp    801063a7 <sys_exec+0x106>
  for(i=0;; i++){
8010639e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801063a2:	e9 5a ff ff ff       	jmp    80106301 <sys_exec+0x60>
}
801063a7:	c9                   	leave
801063a8:	c3                   	ret

801063a9 <sys_pipe>:

int
sys_pipe(void)
{
801063a9:	55                   	push   %ebp
801063aa:	89 e5                	mov    %esp,%ebp
801063ac:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801063af:	83 ec 04             	sub    $0x4,%esp
801063b2:	6a 08                	push   $0x8
801063b4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063b7:	50                   	push   %eax
801063b8:	6a 00                	push   $0x0
801063ba:	e8 36 f2 ff ff       	call   801055f5 <argptr>
801063bf:	83 c4 10             	add    $0x10,%esp
801063c2:	85 c0                	test   %eax,%eax
801063c4:	79 0a                	jns    801063d0 <sys_pipe+0x27>
    return -1;
801063c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063cb:	e9 af 00 00 00       	jmp    8010647f <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
801063d0:	83 ec 08             	sub    $0x8,%esp
801063d3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801063d6:	50                   	push   %eax
801063d7:	8d 45 e8             	lea    -0x18(%ebp),%eax
801063da:	50                   	push   %eax
801063db:	e8 84 dc ff ff       	call   80104064 <pipealloc>
801063e0:	83 c4 10             	add    $0x10,%esp
801063e3:	85 c0                	test   %eax,%eax
801063e5:	79 0a                	jns    801063f1 <sys_pipe+0x48>
    return -1;
801063e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063ec:	e9 8e 00 00 00       	jmp    8010647f <sys_pipe+0xd6>
  fd0 = -1;
801063f1:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801063f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801063fb:	83 ec 0c             	sub    $0xc,%esp
801063fe:	50                   	push   %eax
801063ff:	e8 79 f3 ff ff       	call   8010577d <fdalloc>
80106404:	83 c4 10             	add    $0x10,%esp
80106407:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010640a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010640e:	78 18                	js     80106428 <sys_pipe+0x7f>
80106410:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106413:	83 ec 0c             	sub    $0xc,%esp
80106416:	50                   	push   %eax
80106417:	e8 61 f3 ff ff       	call   8010577d <fdalloc>
8010641c:	83 c4 10             	add    $0x10,%esp
8010641f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106422:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106426:	79 3f                	jns    80106467 <sys_pipe+0xbe>
    if(fd0 >= 0)
80106428:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010642c:	78 14                	js     80106442 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
8010642e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106434:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106437:	83 c2 08             	add    $0x8,%edx
8010643a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106441:	00 
    fileclose(rf);
80106442:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106445:	83 ec 0c             	sub    $0xc,%esp
80106448:	50                   	push   %eax
80106449:	e8 34 ac ff ff       	call   80101082 <fileclose>
8010644e:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106451:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106454:	83 ec 0c             	sub    $0xc,%esp
80106457:	50                   	push   %eax
80106458:	e8 25 ac ff ff       	call   80101082 <fileclose>
8010645d:	83 c4 10             	add    $0x10,%esp
    return -1;
80106460:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106465:	eb 18                	jmp    8010647f <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80106467:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010646a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010646d:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
8010646f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106472:	8d 50 04             	lea    0x4(%eax),%edx
80106475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106478:	89 02                	mov    %eax,(%edx)
  return 0;
8010647a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010647f:	c9                   	leave
80106480:	c3                   	ret

80106481 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106481:	55                   	push   %ebp
80106482:	89 e5                	mov    %esp,%ebp
80106484:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106487:	e8 cf e2 ff ff       	call   8010475b <fork>
}
8010648c:	c9                   	leave
8010648d:	c3                   	ret

8010648e <sys_exit>:

int
sys_exit(void)
{
8010648e:	55                   	push   %ebp
8010648f:	89 e5                	mov    %esp,%ebp
80106491:	83 ec 08             	sub    $0x8,%esp
  exit();
80106494:	e8 4f e4 ff ff       	call   801048e8 <exit>
  return 0;  // not reached
80106499:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010649e:	c9                   	leave
8010649f:	c3                   	ret

801064a0 <sys_wait>:

int
sys_wait(void)
{
801064a0:	55                   	push   %ebp
801064a1:	89 e5                	mov    %esp,%ebp
801064a3:	83 ec 08             	sub    $0x8,%esp
  return wait();
801064a6:	e8 75 e5 ff ff       	call   80104a20 <wait>
}
801064ab:	c9                   	leave
801064ac:	c3                   	ret

801064ad <sys_kill>:

int
sys_kill(void)
{
801064ad:	55                   	push   %ebp
801064ae:	89 e5                	mov    %esp,%ebp
801064b0:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801064b3:	83 ec 08             	sub    $0x8,%esp
801064b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064b9:	50                   	push   %eax
801064ba:	6a 00                	push   $0x0
801064bc:	e8 0c f1 ff ff       	call   801055cd <argint>
801064c1:	83 c4 10             	add    $0x10,%esp
801064c4:	85 c0                	test   %eax,%eax
801064c6:	79 07                	jns    801064cf <sys_kill+0x22>
    return -1;
801064c8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064cd:	eb 0f                	jmp    801064de <sys_kill+0x31>
  return kill(pid);
801064cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064d2:	83 ec 0c             	sub    $0xc,%esp
801064d5:	50                   	push   %eax
801064d6:	e8 92 e9 ff ff       	call   80104e6d <kill>
801064db:	83 c4 10             	add    $0x10,%esp
}
801064de:	c9                   	leave
801064df:	c3                   	ret

801064e0 <sys_getpid>:

int
sys_getpid(void)
{
801064e0:	55                   	push   %ebp
801064e1:	89 e5                	mov    %esp,%ebp
  return proc->pid;
801064e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801064e9:	8b 40 10             	mov    0x10(%eax),%eax
}
801064ec:	5d                   	pop    %ebp
801064ed:	c3                   	ret

801064ee <sys_sbrk>:

int
sys_sbrk(void)
{
801064ee:	55                   	push   %ebp
801064ef:	89 e5                	mov    %esp,%ebp
801064f1:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801064f4:	83 ec 08             	sub    $0x8,%esp
801064f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801064fa:	50                   	push   %eax
801064fb:	6a 00                	push   $0x0
801064fd:	e8 cb f0 ff ff       	call   801055cd <argint>
80106502:	83 c4 10             	add    $0x10,%esp
80106505:	85 c0                	test   %eax,%eax
80106507:	79 07                	jns    80106510 <sys_sbrk+0x22>
    return -1;
80106509:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010650e:	eb 28                	jmp    80106538 <sys_sbrk+0x4a>
  addr = proc->sz;
80106510:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106516:	8b 00                	mov    (%eax),%eax
80106518:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010651b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010651e:	83 ec 0c             	sub    $0xc,%esp
80106521:	50                   	push   %eax
80106522:	e8 91 e1 ff ff       	call   801046b8 <growproc>
80106527:	83 c4 10             	add    $0x10,%esp
8010652a:	85 c0                	test   %eax,%eax
8010652c:	79 07                	jns    80106535 <sys_sbrk+0x47>
    return -1;
8010652e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106533:	eb 03                	jmp    80106538 <sys_sbrk+0x4a>
  return addr;
80106535:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106538:	c9                   	leave
80106539:	c3                   	ret

8010653a <sys_sleep>:

int
sys_sleep(void)
{
8010653a:	55                   	push   %ebp
8010653b:	89 e5                	mov    %esp,%ebp
8010653d:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106540:	83 ec 08             	sub    $0x8,%esp
80106543:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106546:	50                   	push   %eax
80106547:	6a 00                	push   $0x0
80106549:	e8 7f f0 ff ff       	call   801055cd <argint>
8010654e:	83 c4 10             	add    $0x10,%esp
80106551:	85 c0                	test   %eax,%eax
80106553:	79 07                	jns    8010655c <sys_sleep+0x22>
    return -1;
80106555:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010655a:	eb 77                	jmp    801065d3 <sys_sleep+0x99>
  acquire(&tickslock);
8010655c:	83 ec 0c             	sub    $0xc,%esp
8010655f:	68 60 40 11 80       	push   $0x80114060
80106564:	e8 dc ea ff ff       	call   80105045 <acquire>
80106569:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
8010656c:	a1 94 40 11 80       	mov    0x80114094,%eax
80106571:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106574:	eb 39                	jmp    801065af <sys_sleep+0x75>
    if(proc->killed){
80106576:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010657c:	8b 40 24             	mov    0x24(%eax),%eax
8010657f:	85 c0                	test   %eax,%eax
80106581:	74 17                	je     8010659a <sys_sleep+0x60>
      release(&tickslock);
80106583:	83 ec 0c             	sub    $0xc,%esp
80106586:	68 60 40 11 80       	push   $0x80114060
8010658b:	e8 1c eb ff ff       	call   801050ac <release>
80106590:	83 c4 10             	add    $0x10,%esp
      return -1;
80106593:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106598:	eb 39                	jmp    801065d3 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
8010659a:	83 ec 08             	sub    $0x8,%esp
8010659d:	68 60 40 11 80       	push   $0x80114060
801065a2:	68 94 40 11 80       	push   $0x80114094
801065a7:	e8 9e e7 ff ff       	call   80104d4a <sleep>
801065ac:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
801065af:	a1 94 40 11 80       	mov    0x80114094,%eax
801065b4:	2b 45 f4             	sub    -0xc(%ebp),%eax
801065b7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801065ba:	39 d0                	cmp    %edx,%eax
801065bc:	72 b8                	jb     80106576 <sys_sleep+0x3c>
  }
  release(&tickslock);
801065be:	83 ec 0c             	sub    $0xc,%esp
801065c1:	68 60 40 11 80       	push   $0x80114060
801065c6:	e8 e1 ea ff ff       	call   801050ac <release>
801065cb:	83 c4 10             	add    $0x10,%esp
  return 0;
801065ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065d3:	c9                   	leave
801065d4:	c3                   	ret

801065d5 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801065d5:	55                   	push   %ebp
801065d6:	89 e5                	mov    %esp,%ebp
801065d8:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
801065db:	83 ec 0c             	sub    $0xc,%esp
801065de:	68 60 40 11 80       	push   $0x80114060
801065e3:	e8 5d ea ff ff       	call   80105045 <acquire>
801065e8:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801065eb:	a1 94 40 11 80       	mov    0x80114094,%eax
801065f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801065f3:	83 ec 0c             	sub    $0xc,%esp
801065f6:	68 60 40 11 80       	push   $0x80114060
801065fb:	e8 ac ea ff ff       	call   801050ac <release>
80106600:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106603:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106606:	c9                   	leave
80106607:	c3                   	ret

80106608 <outb>:
{
80106608:	55                   	push   %ebp
80106609:	89 e5                	mov    %esp,%ebp
8010660b:	83 ec 08             	sub    $0x8,%esp
8010660e:	8b 55 08             	mov    0x8(%ebp),%edx
80106611:	8b 45 0c             	mov    0xc(%ebp),%eax
80106614:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106618:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010661b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010661f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106623:	ee                   	out    %al,(%dx)
}
80106624:	90                   	nop
80106625:	c9                   	leave
80106626:	c3                   	ret

80106627 <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106627:	55                   	push   %ebp
80106628:	89 e5                	mov    %esp,%ebp
8010662a:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
8010662d:	6a 34                	push   $0x34
8010662f:	6a 43                	push   $0x43
80106631:	e8 d2 ff ff ff       	call   80106608 <outb>
80106636:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106639:	68 9c 00 00 00       	push   $0x9c
8010663e:	6a 40                	push   $0x40
80106640:	e8 c3 ff ff ff       	call   80106608 <outb>
80106645:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106648:	6a 2e                	push   $0x2e
8010664a:	6a 40                	push   $0x40
8010664c:	e8 b7 ff ff ff       	call   80106608 <outb>
80106651:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80106654:	83 ec 0c             	sub    $0xc,%esp
80106657:	6a 00                	push   $0x0
80106659:	e8 f0 d8 ff ff       	call   80103f4e <picenable>
8010665e:	83 c4 10             	add    $0x10,%esp
}
80106661:	90                   	nop
80106662:	c9                   	leave
80106663:	c3                   	ret

80106664 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106664:	1e                   	push   %ds
  pushl %es
80106665:	06                   	push   %es
  pushl %fs
80106666:	0f a0                	push   %fs
  pushl %gs
80106668:	0f a8                	push   %gs
  pushal
8010666a:	60                   	pusha
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010666b:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010666f:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106671:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106673:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106677:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106679:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010667b:	54                   	push   %esp
  call trap
8010667c:	e8 d7 01 00 00       	call   80106858 <trap>
  addl $4, %esp
80106681:	83 c4 04             	add    $0x4,%esp

80106684 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106684:	61                   	popa
  popl %gs
80106685:	0f a9                	pop    %gs
  popl %fs
80106687:	0f a1                	pop    %fs
  popl %es
80106689:	07                   	pop    %es
  popl %ds
8010668a:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010668b:	83 c4 08             	add    $0x8,%esp
  iret
8010668e:	cf                   	iret

8010668f <lidt>:
{
8010668f:	55                   	push   %ebp
80106690:	89 e5                	mov    %esp,%ebp
80106692:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106695:	8b 45 0c             	mov    0xc(%ebp),%eax
80106698:	83 e8 01             	sub    $0x1,%eax
8010669b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010669f:	8b 45 08             	mov    0x8(%ebp),%eax
801066a2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801066a6:	8b 45 08             	mov    0x8(%ebp),%eax
801066a9:	c1 e8 10             	shr    $0x10,%eax
801066ac:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801066b0:	8d 45 fa             	lea    -0x6(%ebp),%eax
801066b3:	0f 01 18             	lidtl  (%eax)
}
801066b6:	90                   	nop
801066b7:	c9                   	leave
801066b8:	c3                   	ret

801066b9 <rcr2>:
{
801066b9:	55                   	push   %ebp
801066ba:	89 e5                	mov    %esp,%ebp
801066bc:	83 ec 10             	sub    $0x10,%esp
  asm volatile("movl %%cr2,%0" : "=r" (val));
801066bf:	0f 20 d0             	mov    %cr2,%eax
801066c2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801066c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801066c8:	c9                   	leave
801066c9:	c3                   	ret

801066ca <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801066ca:	55                   	push   %ebp
801066cb:	89 e5                	mov    %esp,%ebp
801066cd:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801066d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801066d7:	e9 c3 00 00 00       	jmp    8010679f <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801066dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066df:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
801066e6:	89 c2                	mov    %eax,%edx
801066e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066eb:	66 89 14 c5 60 38 11 	mov    %dx,-0x7feec7a0(,%eax,8)
801066f2:	80 
801066f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066f6:	66 c7 04 c5 62 38 11 	movw   $0x8,-0x7feec79e(,%eax,8)
801066fd:	80 08 00 
80106700:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106703:	0f b6 14 c5 64 38 11 	movzbl -0x7feec79c(,%eax,8),%edx
8010670a:	80 
8010670b:	83 e2 e0             	and    $0xffffffe0,%edx
8010670e:	88 14 c5 64 38 11 80 	mov    %dl,-0x7feec79c(,%eax,8)
80106715:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106718:	0f b6 14 c5 64 38 11 	movzbl -0x7feec79c(,%eax,8),%edx
8010671f:	80 
80106720:	83 e2 1f             	and    $0x1f,%edx
80106723:	88 14 c5 64 38 11 80 	mov    %dl,-0x7feec79c(,%eax,8)
8010672a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010672d:	0f b6 14 c5 65 38 11 	movzbl -0x7feec79b(,%eax,8),%edx
80106734:	80 
80106735:	83 e2 f0             	and    $0xfffffff0,%edx
80106738:	83 ca 0e             	or     $0xe,%edx
8010673b:	88 14 c5 65 38 11 80 	mov    %dl,-0x7feec79b(,%eax,8)
80106742:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106745:	0f b6 14 c5 65 38 11 	movzbl -0x7feec79b(,%eax,8),%edx
8010674c:	80 
8010674d:	83 e2 ef             	and    $0xffffffef,%edx
80106750:	88 14 c5 65 38 11 80 	mov    %dl,-0x7feec79b(,%eax,8)
80106757:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010675a:	0f b6 14 c5 65 38 11 	movzbl -0x7feec79b(,%eax,8),%edx
80106761:	80 
80106762:	83 e2 9f             	and    $0xffffff9f,%edx
80106765:	88 14 c5 65 38 11 80 	mov    %dl,-0x7feec79b(,%eax,8)
8010676c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010676f:	0f b6 14 c5 65 38 11 	movzbl -0x7feec79b(,%eax,8),%edx
80106776:	80 
80106777:	83 ca 80             	or     $0xffffff80,%edx
8010677a:	88 14 c5 65 38 11 80 	mov    %dl,-0x7feec79b(,%eax,8)
80106781:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106784:	8b 04 85 98 b0 10 80 	mov    -0x7fef4f68(,%eax,4),%eax
8010678b:	c1 e8 10             	shr    $0x10,%eax
8010678e:	89 c2                	mov    %eax,%edx
80106790:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106793:	66 89 14 c5 66 38 11 	mov    %dx,-0x7feec79a(,%eax,8)
8010679a:	80 
  for(i = 0; i < 256; i++)
8010679b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010679f:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801067a6:	0f 8e 30 ff ff ff    	jle    801066dc <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801067ac:	a1 98 b1 10 80       	mov    0x8010b198,%eax
801067b1:	66 a3 60 3a 11 80    	mov    %ax,0x80113a60
801067b7:	66 c7 05 62 3a 11 80 	movw   $0x8,0x80113a62
801067be:	08 00 
801067c0:	0f b6 05 64 3a 11 80 	movzbl 0x80113a64,%eax
801067c7:	83 e0 e0             	and    $0xffffffe0,%eax
801067ca:	a2 64 3a 11 80       	mov    %al,0x80113a64
801067cf:	0f b6 05 64 3a 11 80 	movzbl 0x80113a64,%eax
801067d6:	83 e0 1f             	and    $0x1f,%eax
801067d9:	a2 64 3a 11 80       	mov    %al,0x80113a64
801067de:	0f b6 05 65 3a 11 80 	movzbl 0x80113a65,%eax
801067e5:	83 c8 0f             	or     $0xf,%eax
801067e8:	a2 65 3a 11 80       	mov    %al,0x80113a65
801067ed:	0f b6 05 65 3a 11 80 	movzbl 0x80113a65,%eax
801067f4:	83 e0 ef             	and    $0xffffffef,%eax
801067f7:	a2 65 3a 11 80       	mov    %al,0x80113a65
801067fc:	0f b6 05 65 3a 11 80 	movzbl 0x80113a65,%eax
80106803:	83 c8 60             	or     $0x60,%eax
80106806:	a2 65 3a 11 80       	mov    %al,0x80113a65
8010680b:	0f b6 05 65 3a 11 80 	movzbl 0x80113a65,%eax
80106812:	83 c8 80             	or     $0xffffff80,%eax
80106815:	a2 65 3a 11 80       	mov    %al,0x80113a65
8010681a:	a1 98 b1 10 80       	mov    0x8010b198,%eax
8010681f:	c1 e8 10             	shr    $0x10,%eax
80106822:	66 a3 66 3a 11 80    	mov    %ax,0x80113a66
  
  initlock(&tickslock, "time");
80106828:	83 ec 08             	sub    $0x8,%esp
8010682b:	68 28 8a 10 80       	push   $0x80108a28
80106830:	68 60 40 11 80       	push   $0x80114060
80106835:	e8 e9 e7 ff ff       	call   80105023 <initlock>
8010683a:	83 c4 10             	add    $0x10,%esp
}
8010683d:	90                   	nop
8010683e:	c9                   	leave
8010683f:	c3                   	ret

80106840 <idtinit>:

void
idtinit(void)
{
80106840:	55                   	push   %ebp
80106841:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106843:	68 00 08 00 00       	push   $0x800
80106848:	68 60 38 11 80       	push   $0x80113860
8010684d:	e8 3d fe ff ff       	call   8010668f <lidt>
80106852:	83 c4 08             	add    $0x8,%esp
}
80106855:	90                   	nop
80106856:	c9                   	leave
80106857:	c3                   	ret

80106858 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106858:	55                   	push   %ebp
80106859:	89 e5                	mov    %esp,%ebp
8010685b:	57                   	push   %edi
8010685c:	56                   	push   %esi
8010685d:	53                   	push   %ebx
8010685e:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80106861:	8b 45 08             	mov    0x8(%ebp),%eax
80106864:	8b 40 30             	mov    0x30(%eax),%eax
80106867:	83 f8 40             	cmp    $0x40,%eax
8010686a:	75 3e                	jne    801068aa <trap+0x52>
    if(proc->killed)
8010686c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106872:	8b 40 24             	mov    0x24(%eax),%eax
80106875:	85 c0                	test   %eax,%eax
80106877:	74 05                	je     8010687e <trap+0x26>
      exit();
80106879:	e8 6a e0 ff ff       	call   801048e8 <exit>
    proc->tf = tf;
8010687e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106884:	8b 55 08             	mov    0x8(%ebp),%edx
80106887:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
8010688a:	e8 f4 ed ff ff       	call   80105683 <syscall>
    if(proc->killed)
8010688f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106895:	8b 40 24             	mov    0x24(%eax),%eax
80106898:	85 c0                	test   %eax,%eax
8010689a:	0f 84 1c 02 00 00    	je     80106abc <trap+0x264>
      exit();
801068a0:	e8 43 e0 ff ff       	call   801048e8 <exit>
    return;
801068a5:	e9 12 02 00 00       	jmp    80106abc <trap+0x264>
  }

  switch(tf->trapno){
801068aa:	8b 45 08             	mov    0x8(%ebp),%eax
801068ad:	8b 40 30             	mov    0x30(%eax),%eax
801068b0:	83 e8 20             	sub    $0x20,%eax
801068b3:	83 f8 1f             	cmp    $0x1f,%eax
801068b6:	0f 87 c0 00 00 00    	ja     8010697c <trap+0x124>
801068bc:	8b 04 85 d0 8a 10 80 	mov    -0x7fef7530(,%eax,4),%eax
801068c3:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
801068c5:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801068cb:	0f b6 00             	movzbl (%eax),%eax
801068ce:	84 c0                	test   %al,%al
801068d0:	75 3d                	jne    8010690f <trap+0xb7>
      acquire(&tickslock);
801068d2:	83 ec 0c             	sub    $0xc,%esp
801068d5:	68 60 40 11 80       	push   $0x80114060
801068da:	e8 66 e7 ff ff       	call   80105045 <acquire>
801068df:	83 c4 10             	add    $0x10,%esp
      ticks++;
801068e2:	a1 94 40 11 80       	mov    0x80114094,%eax
801068e7:	83 c0 01             	add    $0x1,%eax
801068ea:	a3 94 40 11 80       	mov    %eax,0x80114094
      wakeup(&ticks);
801068ef:	83 ec 0c             	sub    $0xc,%esp
801068f2:	68 94 40 11 80       	push   $0x80114094
801068f7:	e8 3a e5 ff ff       	call   80104e36 <wakeup>
801068fc:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
801068ff:	83 ec 0c             	sub    $0xc,%esp
80106902:	68 60 40 11 80       	push   $0x80114060
80106907:	e8 a0 e7 ff ff       	call   801050ac <release>
8010690c:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
8010690f:	e8 22 c7 ff ff       	call   80103036 <lapiceoi>
    break;
80106914:	e9 1d 01 00 00       	jmp    80106a36 <trap+0x1de>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106919:	e8 2c bf ff ff       	call   8010284a <ideintr>
    lapiceoi();
8010691e:	e8 13 c7 ff ff       	call   80103036 <lapiceoi>
    break;
80106923:	e9 0e 01 00 00       	jmp    80106a36 <trap+0x1de>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106928:	e8 0d c5 ff ff       	call   80102e3a <kbdintr>
    lapiceoi();
8010692d:	e8 04 c7 ff ff       	call   80103036 <lapiceoi>
    break;
80106932:	e9 ff 00 00 00       	jmp    80106a36 <trap+0x1de>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106937:	e8 61 03 00 00       	call   80106c9d <uartintr>
    lapiceoi();
8010693c:	e8 f5 c6 ff ff       	call   80103036 <lapiceoi>
    break;
80106941:	e9 f0 00 00 00       	jmp    80106a36 <trap+0x1de>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106946:	8b 45 08             	mov    0x8(%ebp),%eax
80106949:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
8010694c:	8b 45 08             	mov    0x8(%ebp),%eax
8010694f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106953:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106956:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010695c:	0f b6 00             	movzbl (%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010695f:	0f b6 c0             	movzbl %al,%eax
80106962:	51                   	push   %ecx
80106963:	52                   	push   %edx
80106964:	50                   	push   %eax
80106965:	68 30 8a 10 80       	push   $0x80108a30
8010696a:	e8 55 9a ff ff       	call   801003c4 <cprintf>
8010696f:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106972:	e8 bf c6 ff ff       	call   80103036 <lapiceoi>
    break;
80106977:	e9 ba 00 00 00       	jmp    80106a36 <trap+0x1de>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
8010697c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106982:	85 c0                	test   %eax,%eax
80106984:	74 11                	je     80106997 <trap+0x13f>
80106986:	8b 45 08             	mov    0x8(%ebp),%eax
80106989:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
8010698d:	0f b7 c0             	movzwl %ax,%eax
80106990:	83 e0 03             	and    $0x3,%eax
80106993:	85 c0                	test   %eax,%eax
80106995:	75 3f                	jne    801069d6 <trap+0x17e>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106997:	e8 1d fd ff ff       	call   801066b9 <rcr2>
8010699c:	8b 55 08             	mov    0x8(%ebp),%edx
8010699f:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
801069a2:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801069a9:	0f b6 12             	movzbl (%edx),%edx
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801069ac:	0f b6 ca             	movzbl %dl,%ecx
801069af:	8b 55 08             	mov    0x8(%ebp),%edx
801069b2:	8b 52 30             	mov    0x30(%edx),%edx
801069b5:	83 ec 0c             	sub    $0xc,%esp
801069b8:	50                   	push   %eax
801069b9:	53                   	push   %ebx
801069ba:	51                   	push   %ecx
801069bb:	52                   	push   %edx
801069bc:	68 54 8a 10 80       	push   $0x80108a54
801069c1:	e8 fe 99 ff ff       	call   801003c4 <cprintf>
801069c6:	83 c4 20             	add    $0x20,%esp
      panic("trap");
801069c9:	83 ec 0c             	sub    $0xc,%esp
801069cc:	68 86 8a 10 80       	push   $0x80108a86
801069d1:	e8 a3 9b ff ff       	call   80100579 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801069d6:	e8 de fc ff ff       	call   801066b9 <rcr2>
801069db:	89 c2                	mov    %eax,%edx
801069dd:	8b 45 08             	mov    0x8(%ebp),%eax
801069e0:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801069e3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801069e9:	0f b6 00             	movzbl (%eax),%eax
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801069ec:	0f b6 f0             	movzbl %al,%esi
801069ef:	8b 45 08             	mov    0x8(%ebp),%eax
801069f2:	8b 58 34             	mov    0x34(%eax),%ebx
801069f5:	8b 45 08             	mov    0x8(%ebp),%eax
801069f8:	8b 48 30             	mov    0x30(%eax),%ecx
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
801069fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a01:	83 c0 6c             	add    $0x6c,%eax
80106a04:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106a07:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106a0d:	8b 40 10             	mov    0x10(%eax),%eax
80106a10:	52                   	push   %edx
80106a11:	57                   	push   %edi
80106a12:	56                   	push   %esi
80106a13:	53                   	push   %ebx
80106a14:	51                   	push   %ecx
80106a15:	ff 75 e4             	push   -0x1c(%ebp)
80106a18:	50                   	push   %eax
80106a19:	68 8c 8a 10 80       	push   $0x80108a8c
80106a1e:	e8 a1 99 ff ff       	call   801003c4 <cprintf>
80106a23:	83 c4 20             	add    $0x20,%esp
            rcr2());
    proc->killed = 1;
80106a26:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a2c:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106a33:	eb 01                	jmp    80106a36 <trap+0x1de>
    break;
80106a35:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106a36:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a3c:	85 c0                	test   %eax,%eax
80106a3e:	74 24                	je     80106a64 <trap+0x20c>
80106a40:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a46:	8b 40 24             	mov    0x24(%eax),%eax
80106a49:	85 c0                	test   %eax,%eax
80106a4b:	74 17                	je     80106a64 <trap+0x20c>
80106a4d:	8b 45 08             	mov    0x8(%ebp),%eax
80106a50:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106a54:	0f b7 c0             	movzwl %ax,%eax
80106a57:	83 e0 03             	and    $0x3,%eax
80106a5a:	83 f8 03             	cmp    $0x3,%eax
80106a5d:	75 05                	jne    80106a64 <trap+0x20c>
    exit();
80106a5f:	e8 84 de ff ff       	call   801048e8 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106a64:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a6a:	85 c0                	test   %eax,%eax
80106a6c:	74 1e                	je     80106a8c <trap+0x234>
80106a6e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a74:	8b 40 0c             	mov    0xc(%eax),%eax
80106a77:	83 f8 04             	cmp    $0x4,%eax
80106a7a:	75 10                	jne    80106a8c <trap+0x234>
80106a7c:	8b 45 08             	mov    0x8(%ebp),%eax
80106a7f:	8b 40 30             	mov    0x30(%eax),%eax
80106a82:	83 f8 20             	cmp    $0x20,%eax
80106a85:	75 05                	jne    80106a8c <trap+0x234>
    yield();
80106a87:	e8 3d e2 ff ff       	call   80104cc9 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106a8c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a92:	85 c0                	test   %eax,%eax
80106a94:	74 27                	je     80106abd <trap+0x265>
80106a96:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a9c:	8b 40 24             	mov    0x24(%eax),%eax
80106a9f:	85 c0                	test   %eax,%eax
80106aa1:	74 1a                	je     80106abd <trap+0x265>
80106aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80106aa6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106aaa:	0f b7 c0             	movzwl %ax,%eax
80106aad:	83 e0 03             	and    $0x3,%eax
80106ab0:	83 f8 03             	cmp    $0x3,%eax
80106ab3:	75 08                	jne    80106abd <trap+0x265>
    exit();
80106ab5:	e8 2e de ff ff       	call   801048e8 <exit>
80106aba:	eb 01                	jmp    80106abd <trap+0x265>
    return;
80106abc:	90                   	nop
}
80106abd:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106ac0:	5b                   	pop    %ebx
80106ac1:	5e                   	pop    %esi
80106ac2:	5f                   	pop    %edi
80106ac3:	5d                   	pop    %ebp
80106ac4:	c3                   	ret

80106ac5 <inb>:
{
80106ac5:	55                   	push   %ebp
80106ac6:	89 e5                	mov    %esp,%ebp
80106ac8:	83 ec 14             	sub    $0x14,%esp
80106acb:	8b 45 08             	mov    0x8(%ebp),%eax
80106ace:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106ad2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106ad6:	89 c2                	mov    %eax,%edx
80106ad8:	ec                   	in     (%dx),%al
80106ad9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106adc:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106ae0:	c9                   	leave
80106ae1:	c3                   	ret

80106ae2 <outb>:
{
80106ae2:	55                   	push   %ebp
80106ae3:	89 e5                	mov    %esp,%ebp
80106ae5:	83 ec 08             	sub    $0x8,%esp
80106ae8:	8b 55 08             	mov    0x8(%ebp),%edx
80106aeb:	8b 45 0c             	mov    0xc(%ebp),%eax
80106aee:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106af2:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106af5:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106af9:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106afd:	ee                   	out    %al,(%dx)
}
80106afe:	90                   	nop
80106aff:	c9                   	leave
80106b00:	c3                   	ret

80106b01 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106b01:	55                   	push   %ebp
80106b02:	89 e5                	mov    %esp,%ebp
80106b04:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106b07:	6a 00                	push   $0x0
80106b09:	68 fa 03 00 00       	push   $0x3fa
80106b0e:	e8 cf ff ff ff       	call   80106ae2 <outb>
80106b13:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106b16:	68 80 00 00 00       	push   $0x80
80106b1b:	68 fb 03 00 00       	push   $0x3fb
80106b20:	e8 bd ff ff ff       	call   80106ae2 <outb>
80106b25:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106b28:	6a 0c                	push   $0xc
80106b2a:	68 f8 03 00 00       	push   $0x3f8
80106b2f:	e8 ae ff ff ff       	call   80106ae2 <outb>
80106b34:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106b37:	6a 00                	push   $0x0
80106b39:	68 f9 03 00 00       	push   $0x3f9
80106b3e:	e8 9f ff ff ff       	call   80106ae2 <outb>
80106b43:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106b46:	6a 03                	push   $0x3
80106b48:	68 fb 03 00 00       	push   $0x3fb
80106b4d:	e8 90 ff ff ff       	call   80106ae2 <outb>
80106b52:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106b55:	6a 00                	push   $0x0
80106b57:	68 fc 03 00 00       	push   $0x3fc
80106b5c:	e8 81 ff ff ff       	call   80106ae2 <outb>
80106b61:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106b64:	6a 01                	push   $0x1
80106b66:	68 f9 03 00 00       	push   $0x3f9
80106b6b:	e8 72 ff ff ff       	call   80106ae2 <outb>
80106b70:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106b73:	68 fd 03 00 00       	push   $0x3fd
80106b78:	e8 48 ff ff ff       	call   80106ac5 <inb>
80106b7d:	83 c4 04             	add    $0x4,%esp
80106b80:	3c ff                	cmp    $0xff,%al
80106b82:	74 6e                	je     80106bf2 <uartinit+0xf1>
    return;
  uart = 1;
80106b84:	c7 05 98 40 11 80 01 	movl   $0x1,0x80114098
80106b8b:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106b8e:	68 fa 03 00 00       	push   $0x3fa
80106b93:	e8 2d ff ff ff       	call   80106ac5 <inb>
80106b98:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106b9b:	68 f8 03 00 00       	push   $0x3f8
80106ba0:	e8 20 ff ff ff       	call   80106ac5 <inb>
80106ba5:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80106ba8:	83 ec 0c             	sub    $0xc,%esp
80106bab:	6a 04                	push   $0x4
80106bad:	e8 9c d3 ff ff       	call   80103f4e <picenable>
80106bb2:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80106bb5:	83 ec 08             	sub    $0x8,%esp
80106bb8:	6a 00                	push   $0x0
80106bba:	6a 04                	push   $0x4
80106bbc:	e8 2b bf ff ff       	call   80102aec <ioapicenable>
80106bc1:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106bc4:	c7 45 f4 50 8b 10 80 	movl   $0x80108b50,-0xc(%ebp)
80106bcb:	eb 19                	jmp    80106be6 <uartinit+0xe5>
    uartputc(*p);
80106bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bd0:	0f b6 00             	movzbl (%eax),%eax
80106bd3:	0f be c0             	movsbl %al,%eax
80106bd6:	83 ec 0c             	sub    $0xc,%esp
80106bd9:	50                   	push   %eax
80106bda:	e8 16 00 00 00       	call   80106bf5 <uartputc>
80106bdf:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106be2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106be9:	0f b6 00             	movzbl (%eax),%eax
80106bec:	84 c0                	test   %al,%al
80106bee:	75 dd                	jne    80106bcd <uartinit+0xcc>
80106bf0:	eb 01                	jmp    80106bf3 <uartinit+0xf2>
    return;
80106bf2:	90                   	nop
}
80106bf3:	c9                   	leave
80106bf4:	c3                   	ret

80106bf5 <uartputc>:

void
uartputc(int c)
{
80106bf5:	55                   	push   %ebp
80106bf6:	89 e5                	mov    %esp,%ebp
80106bf8:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106bfb:	a1 98 40 11 80       	mov    0x80114098,%eax
80106c00:	85 c0                	test   %eax,%eax
80106c02:	74 53                	je     80106c57 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106c04:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106c0b:	eb 11                	jmp    80106c1e <uartputc+0x29>
    microdelay(10);
80106c0d:	83 ec 0c             	sub    $0xc,%esp
80106c10:	6a 0a                	push   $0xa
80106c12:	e8 3a c4 ff ff       	call   80103051 <microdelay>
80106c17:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106c1a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106c1e:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106c22:	7f 1a                	jg     80106c3e <uartputc+0x49>
80106c24:	83 ec 0c             	sub    $0xc,%esp
80106c27:	68 fd 03 00 00       	push   $0x3fd
80106c2c:	e8 94 fe ff ff       	call   80106ac5 <inb>
80106c31:	83 c4 10             	add    $0x10,%esp
80106c34:	0f b6 c0             	movzbl %al,%eax
80106c37:	83 e0 20             	and    $0x20,%eax
80106c3a:	85 c0                	test   %eax,%eax
80106c3c:	74 cf                	je     80106c0d <uartputc+0x18>
  outb(COM1+0, c);
80106c3e:	8b 45 08             	mov    0x8(%ebp),%eax
80106c41:	0f b6 c0             	movzbl %al,%eax
80106c44:	83 ec 08             	sub    $0x8,%esp
80106c47:	50                   	push   %eax
80106c48:	68 f8 03 00 00       	push   $0x3f8
80106c4d:	e8 90 fe ff ff       	call   80106ae2 <outb>
80106c52:	83 c4 10             	add    $0x10,%esp
80106c55:	eb 01                	jmp    80106c58 <uartputc+0x63>
    return;
80106c57:	90                   	nop
}
80106c58:	c9                   	leave
80106c59:	c3                   	ret

80106c5a <uartgetc>:

static int
uartgetc(void)
{
80106c5a:	55                   	push   %ebp
80106c5b:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106c5d:	a1 98 40 11 80       	mov    0x80114098,%eax
80106c62:	85 c0                	test   %eax,%eax
80106c64:	75 07                	jne    80106c6d <uartgetc+0x13>
    return -1;
80106c66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c6b:	eb 2e                	jmp    80106c9b <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106c6d:	68 fd 03 00 00       	push   $0x3fd
80106c72:	e8 4e fe ff ff       	call   80106ac5 <inb>
80106c77:	83 c4 04             	add    $0x4,%esp
80106c7a:	0f b6 c0             	movzbl %al,%eax
80106c7d:	83 e0 01             	and    $0x1,%eax
80106c80:	85 c0                	test   %eax,%eax
80106c82:	75 07                	jne    80106c8b <uartgetc+0x31>
    return -1;
80106c84:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c89:	eb 10                	jmp    80106c9b <uartgetc+0x41>
  return inb(COM1+0);
80106c8b:	68 f8 03 00 00       	push   $0x3f8
80106c90:	e8 30 fe ff ff       	call   80106ac5 <inb>
80106c95:	83 c4 04             	add    $0x4,%esp
80106c98:	0f b6 c0             	movzbl %al,%eax
}
80106c9b:	c9                   	leave
80106c9c:	c3                   	ret

80106c9d <uartintr>:

void
uartintr(void)
{
80106c9d:	55                   	push   %ebp
80106c9e:	89 e5                	mov    %esp,%ebp
80106ca0:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106ca3:	83 ec 0c             	sub    $0xc,%esp
80106ca6:	68 5a 6c 10 80       	push   $0x80106c5a
80106cab:	e8 66 9b ff ff       	call   80100816 <consoleintr>
80106cb0:	83 c4 10             	add    $0x10,%esp
}
80106cb3:	90                   	nop
80106cb4:	c9                   	leave
80106cb5:	c3                   	ret

80106cb6 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106cb6:	6a 00                	push   $0x0
  pushl $0
80106cb8:	6a 00                	push   $0x0
  jmp alltraps
80106cba:	e9 a5 f9 ff ff       	jmp    80106664 <alltraps>

80106cbf <vector1>:
.globl vector1
vector1:
  pushl $0
80106cbf:	6a 00                	push   $0x0
  pushl $1
80106cc1:	6a 01                	push   $0x1
  jmp alltraps
80106cc3:	e9 9c f9 ff ff       	jmp    80106664 <alltraps>

80106cc8 <vector2>:
.globl vector2
vector2:
  pushl $0
80106cc8:	6a 00                	push   $0x0
  pushl $2
80106cca:	6a 02                	push   $0x2
  jmp alltraps
80106ccc:	e9 93 f9 ff ff       	jmp    80106664 <alltraps>

80106cd1 <vector3>:
.globl vector3
vector3:
  pushl $0
80106cd1:	6a 00                	push   $0x0
  pushl $3
80106cd3:	6a 03                	push   $0x3
  jmp alltraps
80106cd5:	e9 8a f9 ff ff       	jmp    80106664 <alltraps>

80106cda <vector4>:
.globl vector4
vector4:
  pushl $0
80106cda:	6a 00                	push   $0x0
  pushl $4
80106cdc:	6a 04                	push   $0x4
  jmp alltraps
80106cde:	e9 81 f9 ff ff       	jmp    80106664 <alltraps>

80106ce3 <vector5>:
.globl vector5
vector5:
  pushl $0
80106ce3:	6a 00                	push   $0x0
  pushl $5
80106ce5:	6a 05                	push   $0x5
  jmp alltraps
80106ce7:	e9 78 f9 ff ff       	jmp    80106664 <alltraps>

80106cec <vector6>:
.globl vector6
vector6:
  pushl $0
80106cec:	6a 00                	push   $0x0
  pushl $6
80106cee:	6a 06                	push   $0x6
  jmp alltraps
80106cf0:	e9 6f f9 ff ff       	jmp    80106664 <alltraps>

80106cf5 <vector7>:
.globl vector7
vector7:
  pushl $0
80106cf5:	6a 00                	push   $0x0
  pushl $7
80106cf7:	6a 07                	push   $0x7
  jmp alltraps
80106cf9:	e9 66 f9 ff ff       	jmp    80106664 <alltraps>

80106cfe <vector8>:
.globl vector8
vector8:
  pushl $8
80106cfe:	6a 08                	push   $0x8
  jmp alltraps
80106d00:	e9 5f f9 ff ff       	jmp    80106664 <alltraps>

80106d05 <vector9>:
.globl vector9
vector9:
  pushl $0
80106d05:	6a 00                	push   $0x0
  pushl $9
80106d07:	6a 09                	push   $0x9
  jmp alltraps
80106d09:	e9 56 f9 ff ff       	jmp    80106664 <alltraps>

80106d0e <vector10>:
.globl vector10
vector10:
  pushl $10
80106d0e:	6a 0a                	push   $0xa
  jmp alltraps
80106d10:	e9 4f f9 ff ff       	jmp    80106664 <alltraps>

80106d15 <vector11>:
.globl vector11
vector11:
  pushl $11
80106d15:	6a 0b                	push   $0xb
  jmp alltraps
80106d17:	e9 48 f9 ff ff       	jmp    80106664 <alltraps>

80106d1c <vector12>:
.globl vector12
vector12:
  pushl $12
80106d1c:	6a 0c                	push   $0xc
  jmp alltraps
80106d1e:	e9 41 f9 ff ff       	jmp    80106664 <alltraps>

80106d23 <vector13>:
.globl vector13
vector13:
  pushl $13
80106d23:	6a 0d                	push   $0xd
  jmp alltraps
80106d25:	e9 3a f9 ff ff       	jmp    80106664 <alltraps>

80106d2a <vector14>:
.globl vector14
vector14:
  pushl $14
80106d2a:	6a 0e                	push   $0xe
  jmp alltraps
80106d2c:	e9 33 f9 ff ff       	jmp    80106664 <alltraps>

80106d31 <vector15>:
.globl vector15
vector15:
  pushl $0
80106d31:	6a 00                	push   $0x0
  pushl $15
80106d33:	6a 0f                	push   $0xf
  jmp alltraps
80106d35:	e9 2a f9 ff ff       	jmp    80106664 <alltraps>

80106d3a <vector16>:
.globl vector16
vector16:
  pushl $0
80106d3a:	6a 00                	push   $0x0
  pushl $16
80106d3c:	6a 10                	push   $0x10
  jmp alltraps
80106d3e:	e9 21 f9 ff ff       	jmp    80106664 <alltraps>

80106d43 <vector17>:
.globl vector17
vector17:
  pushl $17
80106d43:	6a 11                	push   $0x11
  jmp alltraps
80106d45:	e9 1a f9 ff ff       	jmp    80106664 <alltraps>

80106d4a <vector18>:
.globl vector18
vector18:
  pushl $0
80106d4a:	6a 00                	push   $0x0
  pushl $18
80106d4c:	6a 12                	push   $0x12
  jmp alltraps
80106d4e:	e9 11 f9 ff ff       	jmp    80106664 <alltraps>

80106d53 <vector19>:
.globl vector19
vector19:
  pushl $0
80106d53:	6a 00                	push   $0x0
  pushl $19
80106d55:	6a 13                	push   $0x13
  jmp alltraps
80106d57:	e9 08 f9 ff ff       	jmp    80106664 <alltraps>

80106d5c <vector20>:
.globl vector20
vector20:
  pushl $0
80106d5c:	6a 00                	push   $0x0
  pushl $20
80106d5e:	6a 14                	push   $0x14
  jmp alltraps
80106d60:	e9 ff f8 ff ff       	jmp    80106664 <alltraps>

80106d65 <vector21>:
.globl vector21
vector21:
  pushl $0
80106d65:	6a 00                	push   $0x0
  pushl $21
80106d67:	6a 15                	push   $0x15
  jmp alltraps
80106d69:	e9 f6 f8 ff ff       	jmp    80106664 <alltraps>

80106d6e <vector22>:
.globl vector22
vector22:
  pushl $0
80106d6e:	6a 00                	push   $0x0
  pushl $22
80106d70:	6a 16                	push   $0x16
  jmp alltraps
80106d72:	e9 ed f8 ff ff       	jmp    80106664 <alltraps>

80106d77 <vector23>:
.globl vector23
vector23:
  pushl $0
80106d77:	6a 00                	push   $0x0
  pushl $23
80106d79:	6a 17                	push   $0x17
  jmp alltraps
80106d7b:	e9 e4 f8 ff ff       	jmp    80106664 <alltraps>

80106d80 <vector24>:
.globl vector24
vector24:
  pushl $0
80106d80:	6a 00                	push   $0x0
  pushl $24
80106d82:	6a 18                	push   $0x18
  jmp alltraps
80106d84:	e9 db f8 ff ff       	jmp    80106664 <alltraps>

80106d89 <vector25>:
.globl vector25
vector25:
  pushl $0
80106d89:	6a 00                	push   $0x0
  pushl $25
80106d8b:	6a 19                	push   $0x19
  jmp alltraps
80106d8d:	e9 d2 f8 ff ff       	jmp    80106664 <alltraps>

80106d92 <vector26>:
.globl vector26
vector26:
  pushl $0
80106d92:	6a 00                	push   $0x0
  pushl $26
80106d94:	6a 1a                	push   $0x1a
  jmp alltraps
80106d96:	e9 c9 f8 ff ff       	jmp    80106664 <alltraps>

80106d9b <vector27>:
.globl vector27
vector27:
  pushl $0
80106d9b:	6a 00                	push   $0x0
  pushl $27
80106d9d:	6a 1b                	push   $0x1b
  jmp alltraps
80106d9f:	e9 c0 f8 ff ff       	jmp    80106664 <alltraps>

80106da4 <vector28>:
.globl vector28
vector28:
  pushl $0
80106da4:	6a 00                	push   $0x0
  pushl $28
80106da6:	6a 1c                	push   $0x1c
  jmp alltraps
80106da8:	e9 b7 f8 ff ff       	jmp    80106664 <alltraps>

80106dad <vector29>:
.globl vector29
vector29:
  pushl $0
80106dad:	6a 00                	push   $0x0
  pushl $29
80106daf:	6a 1d                	push   $0x1d
  jmp alltraps
80106db1:	e9 ae f8 ff ff       	jmp    80106664 <alltraps>

80106db6 <vector30>:
.globl vector30
vector30:
  pushl $0
80106db6:	6a 00                	push   $0x0
  pushl $30
80106db8:	6a 1e                	push   $0x1e
  jmp alltraps
80106dba:	e9 a5 f8 ff ff       	jmp    80106664 <alltraps>

80106dbf <vector31>:
.globl vector31
vector31:
  pushl $0
80106dbf:	6a 00                	push   $0x0
  pushl $31
80106dc1:	6a 1f                	push   $0x1f
  jmp alltraps
80106dc3:	e9 9c f8 ff ff       	jmp    80106664 <alltraps>

80106dc8 <vector32>:
.globl vector32
vector32:
  pushl $0
80106dc8:	6a 00                	push   $0x0
  pushl $32
80106dca:	6a 20                	push   $0x20
  jmp alltraps
80106dcc:	e9 93 f8 ff ff       	jmp    80106664 <alltraps>

80106dd1 <vector33>:
.globl vector33
vector33:
  pushl $0
80106dd1:	6a 00                	push   $0x0
  pushl $33
80106dd3:	6a 21                	push   $0x21
  jmp alltraps
80106dd5:	e9 8a f8 ff ff       	jmp    80106664 <alltraps>

80106dda <vector34>:
.globl vector34
vector34:
  pushl $0
80106dda:	6a 00                	push   $0x0
  pushl $34
80106ddc:	6a 22                	push   $0x22
  jmp alltraps
80106dde:	e9 81 f8 ff ff       	jmp    80106664 <alltraps>

80106de3 <vector35>:
.globl vector35
vector35:
  pushl $0
80106de3:	6a 00                	push   $0x0
  pushl $35
80106de5:	6a 23                	push   $0x23
  jmp alltraps
80106de7:	e9 78 f8 ff ff       	jmp    80106664 <alltraps>

80106dec <vector36>:
.globl vector36
vector36:
  pushl $0
80106dec:	6a 00                	push   $0x0
  pushl $36
80106dee:	6a 24                	push   $0x24
  jmp alltraps
80106df0:	e9 6f f8 ff ff       	jmp    80106664 <alltraps>

80106df5 <vector37>:
.globl vector37
vector37:
  pushl $0
80106df5:	6a 00                	push   $0x0
  pushl $37
80106df7:	6a 25                	push   $0x25
  jmp alltraps
80106df9:	e9 66 f8 ff ff       	jmp    80106664 <alltraps>

80106dfe <vector38>:
.globl vector38
vector38:
  pushl $0
80106dfe:	6a 00                	push   $0x0
  pushl $38
80106e00:	6a 26                	push   $0x26
  jmp alltraps
80106e02:	e9 5d f8 ff ff       	jmp    80106664 <alltraps>

80106e07 <vector39>:
.globl vector39
vector39:
  pushl $0
80106e07:	6a 00                	push   $0x0
  pushl $39
80106e09:	6a 27                	push   $0x27
  jmp alltraps
80106e0b:	e9 54 f8 ff ff       	jmp    80106664 <alltraps>

80106e10 <vector40>:
.globl vector40
vector40:
  pushl $0
80106e10:	6a 00                	push   $0x0
  pushl $40
80106e12:	6a 28                	push   $0x28
  jmp alltraps
80106e14:	e9 4b f8 ff ff       	jmp    80106664 <alltraps>

80106e19 <vector41>:
.globl vector41
vector41:
  pushl $0
80106e19:	6a 00                	push   $0x0
  pushl $41
80106e1b:	6a 29                	push   $0x29
  jmp alltraps
80106e1d:	e9 42 f8 ff ff       	jmp    80106664 <alltraps>

80106e22 <vector42>:
.globl vector42
vector42:
  pushl $0
80106e22:	6a 00                	push   $0x0
  pushl $42
80106e24:	6a 2a                	push   $0x2a
  jmp alltraps
80106e26:	e9 39 f8 ff ff       	jmp    80106664 <alltraps>

80106e2b <vector43>:
.globl vector43
vector43:
  pushl $0
80106e2b:	6a 00                	push   $0x0
  pushl $43
80106e2d:	6a 2b                	push   $0x2b
  jmp alltraps
80106e2f:	e9 30 f8 ff ff       	jmp    80106664 <alltraps>

80106e34 <vector44>:
.globl vector44
vector44:
  pushl $0
80106e34:	6a 00                	push   $0x0
  pushl $44
80106e36:	6a 2c                	push   $0x2c
  jmp alltraps
80106e38:	e9 27 f8 ff ff       	jmp    80106664 <alltraps>

80106e3d <vector45>:
.globl vector45
vector45:
  pushl $0
80106e3d:	6a 00                	push   $0x0
  pushl $45
80106e3f:	6a 2d                	push   $0x2d
  jmp alltraps
80106e41:	e9 1e f8 ff ff       	jmp    80106664 <alltraps>

80106e46 <vector46>:
.globl vector46
vector46:
  pushl $0
80106e46:	6a 00                	push   $0x0
  pushl $46
80106e48:	6a 2e                	push   $0x2e
  jmp alltraps
80106e4a:	e9 15 f8 ff ff       	jmp    80106664 <alltraps>

80106e4f <vector47>:
.globl vector47
vector47:
  pushl $0
80106e4f:	6a 00                	push   $0x0
  pushl $47
80106e51:	6a 2f                	push   $0x2f
  jmp alltraps
80106e53:	e9 0c f8 ff ff       	jmp    80106664 <alltraps>

80106e58 <vector48>:
.globl vector48
vector48:
  pushl $0
80106e58:	6a 00                	push   $0x0
  pushl $48
80106e5a:	6a 30                	push   $0x30
  jmp alltraps
80106e5c:	e9 03 f8 ff ff       	jmp    80106664 <alltraps>

80106e61 <vector49>:
.globl vector49
vector49:
  pushl $0
80106e61:	6a 00                	push   $0x0
  pushl $49
80106e63:	6a 31                	push   $0x31
  jmp alltraps
80106e65:	e9 fa f7 ff ff       	jmp    80106664 <alltraps>

80106e6a <vector50>:
.globl vector50
vector50:
  pushl $0
80106e6a:	6a 00                	push   $0x0
  pushl $50
80106e6c:	6a 32                	push   $0x32
  jmp alltraps
80106e6e:	e9 f1 f7 ff ff       	jmp    80106664 <alltraps>

80106e73 <vector51>:
.globl vector51
vector51:
  pushl $0
80106e73:	6a 00                	push   $0x0
  pushl $51
80106e75:	6a 33                	push   $0x33
  jmp alltraps
80106e77:	e9 e8 f7 ff ff       	jmp    80106664 <alltraps>

80106e7c <vector52>:
.globl vector52
vector52:
  pushl $0
80106e7c:	6a 00                	push   $0x0
  pushl $52
80106e7e:	6a 34                	push   $0x34
  jmp alltraps
80106e80:	e9 df f7 ff ff       	jmp    80106664 <alltraps>

80106e85 <vector53>:
.globl vector53
vector53:
  pushl $0
80106e85:	6a 00                	push   $0x0
  pushl $53
80106e87:	6a 35                	push   $0x35
  jmp alltraps
80106e89:	e9 d6 f7 ff ff       	jmp    80106664 <alltraps>

80106e8e <vector54>:
.globl vector54
vector54:
  pushl $0
80106e8e:	6a 00                	push   $0x0
  pushl $54
80106e90:	6a 36                	push   $0x36
  jmp alltraps
80106e92:	e9 cd f7 ff ff       	jmp    80106664 <alltraps>

80106e97 <vector55>:
.globl vector55
vector55:
  pushl $0
80106e97:	6a 00                	push   $0x0
  pushl $55
80106e99:	6a 37                	push   $0x37
  jmp alltraps
80106e9b:	e9 c4 f7 ff ff       	jmp    80106664 <alltraps>

80106ea0 <vector56>:
.globl vector56
vector56:
  pushl $0
80106ea0:	6a 00                	push   $0x0
  pushl $56
80106ea2:	6a 38                	push   $0x38
  jmp alltraps
80106ea4:	e9 bb f7 ff ff       	jmp    80106664 <alltraps>

80106ea9 <vector57>:
.globl vector57
vector57:
  pushl $0
80106ea9:	6a 00                	push   $0x0
  pushl $57
80106eab:	6a 39                	push   $0x39
  jmp alltraps
80106ead:	e9 b2 f7 ff ff       	jmp    80106664 <alltraps>

80106eb2 <vector58>:
.globl vector58
vector58:
  pushl $0
80106eb2:	6a 00                	push   $0x0
  pushl $58
80106eb4:	6a 3a                	push   $0x3a
  jmp alltraps
80106eb6:	e9 a9 f7 ff ff       	jmp    80106664 <alltraps>

80106ebb <vector59>:
.globl vector59
vector59:
  pushl $0
80106ebb:	6a 00                	push   $0x0
  pushl $59
80106ebd:	6a 3b                	push   $0x3b
  jmp alltraps
80106ebf:	e9 a0 f7 ff ff       	jmp    80106664 <alltraps>

80106ec4 <vector60>:
.globl vector60
vector60:
  pushl $0
80106ec4:	6a 00                	push   $0x0
  pushl $60
80106ec6:	6a 3c                	push   $0x3c
  jmp alltraps
80106ec8:	e9 97 f7 ff ff       	jmp    80106664 <alltraps>

80106ecd <vector61>:
.globl vector61
vector61:
  pushl $0
80106ecd:	6a 00                	push   $0x0
  pushl $61
80106ecf:	6a 3d                	push   $0x3d
  jmp alltraps
80106ed1:	e9 8e f7 ff ff       	jmp    80106664 <alltraps>

80106ed6 <vector62>:
.globl vector62
vector62:
  pushl $0
80106ed6:	6a 00                	push   $0x0
  pushl $62
80106ed8:	6a 3e                	push   $0x3e
  jmp alltraps
80106eda:	e9 85 f7 ff ff       	jmp    80106664 <alltraps>

80106edf <vector63>:
.globl vector63
vector63:
  pushl $0
80106edf:	6a 00                	push   $0x0
  pushl $63
80106ee1:	6a 3f                	push   $0x3f
  jmp alltraps
80106ee3:	e9 7c f7 ff ff       	jmp    80106664 <alltraps>

80106ee8 <vector64>:
.globl vector64
vector64:
  pushl $0
80106ee8:	6a 00                	push   $0x0
  pushl $64
80106eea:	6a 40                	push   $0x40
  jmp alltraps
80106eec:	e9 73 f7 ff ff       	jmp    80106664 <alltraps>

80106ef1 <vector65>:
.globl vector65
vector65:
  pushl $0
80106ef1:	6a 00                	push   $0x0
  pushl $65
80106ef3:	6a 41                	push   $0x41
  jmp alltraps
80106ef5:	e9 6a f7 ff ff       	jmp    80106664 <alltraps>

80106efa <vector66>:
.globl vector66
vector66:
  pushl $0
80106efa:	6a 00                	push   $0x0
  pushl $66
80106efc:	6a 42                	push   $0x42
  jmp alltraps
80106efe:	e9 61 f7 ff ff       	jmp    80106664 <alltraps>

80106f03 <vector67>:
.globl vector67
vector67:
  pushl $0
80106f03:	6a 00                	push   $0x0
  pushl $67
80106f05:	6a 43                	push   $0x43
  jmp alltraps
80106f07:	e9 58 f7 ff ff       	jmp    80106664 <alltraps>

80106f0c <vector68>:
.globl vector68
vector68:
  pushl $0
80106f0c:	6a 00                	push   $0x0
  pushl $68
80106f0e:	6a 44                	push   $0x44
  jmp alltraps
80106f10:	e9 4f f7 ff ff       	jmp    80106664 <alltraps>

80106f15 <vector69>:
.globl vector69
vector69:
  pushl $0
80106f15:	6a 00                	push   $0x0
  pushl $69
80106f17:	6a 45                	push   $0x45
  jmp alltraps
80106f19:	e9 46 f7 ff ff       	jmp    80106664 <alltraps>

80106f1e <vector70>:
.globl vector70
vector70:
  pushl $0
80106f1e:	6a 00                	push   $0x0
  pushl $70
80106f20:	6a 46                	push   $0x46
  jmp alltraps
80106f22:	e9 3d f7 ff ff       	jmp    80106664 <alltraps>

80106f27 <vector71>:
.globl vector71
vector71:
  pushl $0
80106f27:	6a 00                	push   $0x0
  pushl $71
80106f29:	6a 47                	push   $0x47
  jmp alltraps
80106f2b:	e9 34 f7 ff ff       	jmp    80106664 <alltraps>

80106f30 <vector72>:
.globl vector72
vector72:
  pushl $0
80106f30:	6a 00                	push   $0x0
  pushl $72
80106f32:	6a 48                	push   $0x48
  jmp alltraps
80106f34:	e9 2b f7 ff ff       	jmp    80106664 <alltraps>

80106f39 <vector73>:
.globl vector73
vector73:
  pushl $0
80106f39:	6a 00                	push   $0x0
  pushl $73
80106f3b:	6a 49                	push   $0x49
  jmp alltraps
80106f3d:	e9 22 f7 ff ff       	jmp    80106664 <alltraps>

80106f42 <vector74>:
.globl vector74
vector74:
  pushl $0
80106f42:	6a 00                	push   $0x0
  pushl $74
80106f44:	6a 4a                	push   $0x4a
  jmp alltraps
80106f46:	e9 19 f7 ff ff       	jmp    80106664 <alltraps>

80106f4b <vector75>:
.globl vector75
vector75:
  pushl $0
80106f4b:	6a 00                	push   $0x0
  pushl $75
80106f4d:	6a 4b                	push   $0x4b
  jmp alltraps
80106f4f:	e9 10 f7 ff ff       	jmp    80106664 <alltraps>

80106f54 <vector76>:
.globl vector76
vector76:
  pushl $0
80106f54:	6a 00                	push   $0x0
  pushl $76
80106f56:	6a 4c                	push   $0x4c
  jmp alltraps
80106f58:	e9 07 f7 ff ff       	jmp    80106664 <alltraps>

80106f5d <vector77>:
.globl vector77
vector77:
  pushl $0
80106f5d:	6a 00                	push   $0x0
  pushl $77
80106f5f:	6a 4d                	push   $0x4d
  jmp alltraps
80106f61:	e9 fe f6 ff ff       	jmp    80106664 <alltraps>

80106f66 <vector78>:
.globl vector78
vector78:
  pushl $0
80106f66:	6a 00                	push   $0x0
  pushl $78
80106f68:	6a 4e                	push   $0x4e
  jmp alltraps
80106f6a:	e9 f5 f6 ff ff       	jmp    80106664 <alltraps>

80106f6f <vector79>:
.globl vector79
vector79:
  pushl $0
80106f6f:	6a 00                	push   $0x0
  pushl $79
80106f71:	6a 4f                	push   $0x4f
  jmp alltraps
80106f73:	e9 ec f6 ff ff       	jmp    80106664 <alltraps>

80106f78 <vector80>:
.globl vector80
vector80:
  pushl $0
80106f78:	6a 00                	push   $0x0
  pushl $80
80106f7a:	6a 50                	push   $0x50
  jmp alltraps
80106f7c:	e9 e3 f6 ff ff       	jmp    80106664 <alltraps>

80106f81 <vector81>:
.globl vector81
vector81:
  pushl $0
80106f81:	6a 00                	push   $0x0
  pushl $81
80106f83:	6a 51                	push   $0x51
  jmp alltraps
80106f85:	e9 da f6 ff ff       	jmp    80106664 <alltraps>

80106f8a <vector82>:
.globl vector82
vector82:
  pushl $0
80106f8a:	6a 00                	push   $0x0
  pushl $82
80106f8c:	6a 52                	push   $0x52
  jmp alltraps
80106f8e:	e9 d1 f6 ff ff       	jmp    80106664 <alltraps>

80106f93 <vector83>:
.globl vector83
vector83:
  pushl $0
80106f93:	6a 00                	push   $0x0
  pushl $83
80106f95:	6a 53                	push   $0x53
  jmp alltraps
80106f97:	e9 c8 f6 ff ff       	jmp    80106664 <alltraps>

80106f9c <vector84>:
.globl vector84
vector84:
  pushl $0
80106f9c:	6a 00                	push   $0x0
  pushl $84
80106f9e:	6a 54                	push   $0x54
  jmp alltraps
80106fa0:	e9 bf f6 ff ff       	jmp    80106664 <alltraps>

80106fa5 <vector85>:
.globl vector85
vector85:
  pushl $0
80106fa5:	6a 00                	push   $0x0
  pushl $85
80106fa7:	6a 55                	push   $0x55
  jmp alltraps
80106fa9:	e9 b6 f6 ff ff       	jmp    80106664 <alltraps>

80106fae <vector86>:
.globl vector86
vector86:
  pushl $0
80106fae:	6a 00                	push   $0x0
  pushl $86
80106fb0:	6a 56                	push   $0x56
  jmp alltraps
80106fb2:	e9 ad f6 ff ff       	jmp    80106664 <alltraps>

80106fb7 <vector87>:
.globl vector87
vector87:
  pushl $0
80106fb7:	6a 00                	push   $0x0
  pushl $87
80106fb9:	6a 57                	push   $0x57
  jmp alltraps
80106fbb:	e9 a4 f6 ff ff       	jmp    80106664 <alltraps>

80106fc0 <vector88>:
.globl vector88
vector88:
  pushl $0
80106fc0:	6a 00                	push   $0x0
  pushl $88
80106fc2:	6a 58                	push   $0x58
  jmp alltraps
80106fc4:	e9 9b f6 ff ff       	jmp    80106664 <alltraps>

80106fc9 <vector89>:
.globl vector89
vector89:
  pushl $0
80106fc9:	6a 00                	push   $0x0
  pushl $89
80106fcb:	6a 59                	push   $0x59
  jmp alltraps
80106fcd:	e9 92 f6 ff ff       	jmp    80106664 <alltraps>

80106fd2 <vector90>:
.globl vector90
vector90:
  pushl $0
80106fd2:	6a 00                	push   $0x0
  pushl $90
80106fd4:	6a 5a                	push   $0x5a
  jmp alltraps
80106fd6:	e9 89 f6 ff ff       	jmp    80106664 <alltraps>

80106fdb <vector91>:
.globl vector91
vector91:
  pushl $0
80106fdb:	6a 00                	push   $0x0
  pushl $91
80106fdd:	6a 5b                	push   $0x5b
  jmp alltraps
80106fdf:	e9 80 f6 ff ff       	jmp    80106664 <alltraps>

80106fe4 <vector92>:
.globl vector92
vector92:
  pushl $0
80106fe4:	6a 00                	push   $0x0
  pushl $92
80106fe6:	6a 5c                	push   $0x5c
  jmp alltraps
80106fe8:	e9 77 f6 ff ff       	jmp    80106664 <alltraps>

80106fed <vector93>:
.globl vector93
vector93:
  pushl $0
80106fed:	6a 00                	push   $0x0
  pushl $93
80106fef:	6a 5d                	push   $0x5d
  jmp alltraps
80106ff1:	e9 6e f6 ff ff       	jmp    80106664 <alltraps>

80106ff6 <vector94>:
.globl vector94
vector94:
  pushl $0
80106ff6:	6a 00                	push   $0x0
  pushl $94
80106ff8:	6a 5e                	push   $0x5e
  jmp alltraps
80106ffa:	e9 65 f6 ff ff       	jmp    80106664 <alltraps>

80106fff <vector95>:
.globl vector95
vector95:
  pushl $0
80106fff:	6a 00                	push   $0x0
  pushl $95
80107001:	6a 5f                	push   $0x5f
  jmp alltraps
80107003:	e9 5c f6 ff ff       	jmp    80106664 <alltraps>

80107008 <vector96>:
.globl vector96
vector96:
  pushl $0
80107008:	6a 00                	push   $0x0
  pushl $96
8010700a:	6a 60                	push   $0x60
  jmp alltraps
8010700c:	e9 53 f6 ff ff       	jmp    80106664 <alltraps>

80107011 <vector97>:
.globl vector97
vector97:
  pushl $0
80107011:	6a 00                	push   $0x0
  pushl $97
80107013:	6a 61                	push   $0x61
  jmp alltraps
80107015:	e9 4a f6 ff ff       	jmp    80106664 <alltraps>

8010701a <vector98>:
.globl vector98
vector98:
  pushl $0
8010701a:	6a 00                	push   $0x0
  pushl $98
8010701c:	6a 62                	push   $0x62
  jmp alltraps
8010701e:	e9 41 f6 ff ff       	jmp    80106664 <alltraps>

80107023 <vector99>:
.globl vector99
vector99:
  pushl $0
80107023:	6a 00                	push   $0x0
  pushl $99
80107025:	6a 63                	push   $0x63
  jmp alltraps
80107027:	e9 38 f6 ff ff       	jmp    80106664 <alltraps>

8010702c <vector100>:
.globl vector100
vector100:
  pushl $0
8010702c:	6a 00                	push   $0x0
  pushl $100
8010702e:	6a 64                	push   $0x64
  jmp alltraps
80107030:	e9 2f f6 ff ff       	jmp    80106664 <alltraps>

80107035 <vector101>:
.globl vector101
vector101:
  pushl $0
80107035:	6a 00                	push   $0x0
  pushl $101
80107037:	6a 65                	push   $0x65
  jmp alltraps
80107039:	e9 26 f6 ff ff       	jmp    80106664 <alltraps>

8010703e <vector102>:
.globl vector102
vector102:
  pushl $0
8010703e:	6a 00                	push   $0x0
  pushl $102
80107040:	6a 66                	push   $0x66
  jmp alltraps
80107042:	e9 1d f6 ff ff       	jmp    80106664 <alltraps>

80107047 <vector103>:
.globl vector103
vector103:
  pushl $0
80107047:	6a 00                	push   $0x0
  pushl $103
80107049:	6a 67                	push   $0x67
  jmp alltraps
8010704b:	e9 14 f6 ff ff       	jmp    80106664 <alltraps>

80107050 <vector104>:
.globl vector104
vector104:
  pushl $0
80107050:	6a 00                	push   $0x0
  pushl $104
80107052:	6a 68                	push   $0x68
  jmp alltraps
80107054:	e9 0b f6 ff ff       	jmp    80106664 <alltraps>

80107059 <vector105>:
.globl vector105
vector105:
  pushl $0
80107059:	6a 00                	push   $0x0
  pushl $105
8010705b:	6a 69                	push   $0x69
  jmp alltraps
8010705d:	e9 02 f6 ff ff       	jmp    80106664 <alltraps>

80107062 <vector106>:
.globl vector106
vector106:
  pushl $0
80107062:	6a 00                	push   $0x0
  pushl $106
80107064:	6a 6a                	push   $0x6a
  jmp alltraps
80107066:	e9 f9 f5 ff ff       	jmp    80106664 <alltraps>

8010706b <vector107>:
.globl vector107
vector107:
  pushl $0
8010706b:	6a 00                	push   $0x0
  pushl $107
8010706d:	6a 6b                	push   $0x6b
  jmp alltraps
8010706f:	e9 f0 f5 ff ff       	jmp    80106664 <alltraps>

80107074 <vector108>:
.globl vector108
vector108:
  pushl $0
80107074:	6a 00                	push   $0x0
  pushl $108
80107076:	6a 6c                	push   $0x6c
  jmp alltraps
80107078:	e9 e7 f5 ff ff       	jmp    80106664 <alltraps>

8010707d <vector109>:
.globl vector109
vector109:
  pushl $0
8010707d:	6a 00                	push   $0x0
  pushl $109
8010707f:	6a 6d                	push   $0x6d
  jmp alltraps
80107081:	e9 de f5 ff ff       	jmp    80106664 <alltraps>

80107086 <vector110>:
.globl vector110
vector110:
  pushl $0
80107086:	6a 00                	push   $0x0
  pushl $110
80107088:	6a 6e                	push   $0x6e
  jmp alltraps
8010708a:	e9 d5 f5 ff ff       	jmp    80106664 <alltraps>

8010708f <vector111>:
.globl vector111
vector111:
  pushl $0
8010708f:	6a 00                	push   $0x0
  pushl $111
80107091:	6a 6f                	push   $0x6f
  jmp alltraps
80107093:	e9 cc f5 ff ff       	jmp    80106664 <alltraps>

80107098 <vector112>:
.globl vector112
vector112:
  pushl $0
80107098:	6a 00                	push   $0x0
  pushl $112
8010709a:	6a 70                	push   $0x70
  jmp alltraps
8010709c:	e9 c3 f5 ff ff       	jmp    80106664 <alltraps>

801070a1 <vector113>:
.globl vector113
vector113:
  pushl $0
801070a1:	6a 00                	push   $0x0
  pushl $113
801070a3:	6a 71                	push   $0x71
  jmp alltraps
801070a5:	e9 ba f5 ff ff       	jmp    80106664 <alltraps>

801070aa <vector114>:
.globl vector114
vector114:
  pushl $0
801070aa:	6a 00                	push   $0x0
  pushl $114
801070ac:	6a 72                	push   $0x72
  jmp alltraps
801070ae:	e9 b1 f5 ff ff       	jmp    80106664 <alltraps>

801070b3 <vector115>:
.globl vector115
vector115:
  pushl $0
801070b3:	6a 00                	push   $0x0
  pushl $115
801070b5:	6a 73                	push   $0x73
  jmp alltraps
801070b7:	e9 a8 f5 ff ff       	jmp    80106664 <alltraps>

801070bc <vector116>:
.globl vector116
vector116:
  pushl $0
801070bc:	6a 00                	push   $0x0
  pushl $116
801070be:	6a 74                	push   $0x74
  jmp alltraps
801070c0:	e9 9f f5 ff ff       	jmp    80106664 <alltraps>

801070c5 <vector117>:
.globl vector117
vector117:
  pushl $0
801070c5:	6a 00                	push   $0x0
  pushl $117
801070c7:	6a 75                	push   $0x75
  jmp alltraps
801070c9:	e9 96 f5 ff ff       	jmp    80106664 <alltraps>

801070ce <vector118>:
.globl vector118
vector118:
  pushl $0
801070ce:	6a 00                	push   $0x0
  pushl $118
801070d0:	6a 76                	push   $0x76
  jmp alltraps
801070d2:	e9 8d f5 ff ff       	jmp    80106664 <alltraps>

801070d7 <vector119>:
.globl vector119
vector119:
  pushl $0
801070d7:	6a 00                	push   $0x0
  pushl $119
801070d9:	6a 77                	push   $0x77
  jmp alltraps
801070db:	e9 84 f5 ff ff       	jmp    80106664 <alltraps>

801070e0 <vector120>:
.globl vector120
vector120:
  pushl $0
801070e0:	6a 00                	push   $0x0
  pushl $120
801070e2:	6a 78                	push   $0x78
  jmp alltraps
801070e4:	e9 7b f5 ff ff       	jmp    80106664 <alltraps>

801070e9 <vector121>:
.globl vector121
vector121:
  pushl $0
801070e9:	6a 00                	push   $0x0
  pushl $121
801070eb:	6a 79                	push   $0x79
  jmp alltraps
801070ed:	e9 72 f5 ff ff       	jmp    80106664 <alltraps>

801070f2 <vector122>:
.globl vector122
vector122:
  pushl $0
801070f2:	6a 00                	push   $0x0
  pushl $122
801070f4:	6a 7a                	push   $0x7a
  jmp alltraps
801070f6:	e9 69 f5 ff ff       	jmp    80106664 <alltraps>

801070fb <vector123>:
.globl vector123
vector123:
  pushl $0
801070fb:	6a 00                	push   $0x0
  pushl $123
801070fd:	6a 7b                	push   $0x7b
  jmp alltraps
801070ff:	e9 60 f5 ff ff       	jmp    80106664 <alltraps>

80107104 <vector124>:
.globl vector124
vector124:
  pushl $0
80107104:	6a 00                	push   $0x0
  pushl $124
80107106:	6a 7c                	push   $0x7c
  jmp alltraps
80107108:	e9 57 f5 ff ff       	jmp    80106664 <alltraps>

8010710d <vector125>:
.globl vector125
vector125:
  pushl $0
8010710d:	6a 00                	push   $0x0
  pushl $125
8010710f:	6a 7d                	push   $0x7d
  jmp alltraps
80107111:	e9 4e f5 ff ff       	jmp    80106664 <alltraps>

80107116 <vector126>:
.globl vector126
vector126:
  pushl $0
80107116:	6a 00                	push   $0x0
  pushl $126
80107118:	6a 7e                	push   $0x7e
  jmp alltraps
8010711a:	e9 45 f5 ff ff       	jmp    80106664 <alltraps>

8010711f <vector127>:
.globl vector127
vector127:
  pushl $0
8010711f:	6a 00                	push   $0x0
  pushl $127
80107121:	6a 7f                	push   $0x7f
  jmp alltraps
80107123:	e9 3c f5 ff ff       	jmp    80106664 <alltraps>

80107128 <vector128>:
.globl vector128
vector128:
  pushl $0
80107128:	6a 00                	push   $0x0
  pushl $128
8010712a:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010712f:	e9 30 f5 ff ff       	jmp    80106664 <alltraps>

80107134 <vector129>:
.globl vector129
vector129:
  pushl $0
80107134:	6a 00                	push   $0x0
  pushl $129
80107136:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010713b:	e9 24 f5 ff ff       	jmp    80106664 <alltraps>

80107140 <vector130>:
.globl vector130
vector130:
  pushl $0
80107140:	6a 00                	push   $0x0
  pushl $130
80107142:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107147:	e9 18 f5 ff ff       	jmp    80106664 <alltraps>

8010714c <vector131>:
.globl vector131
vector131:
  pushl $0
8010714c:	6a 00                	push   $0x0
  pushl $131
8010714e:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107153:	e9 0c f5 ff ff       	jmp    80106664 <alltraps>

80107158 <vector132>:
.globl vector132
vector132:
  pushl $0
80107158:	6a 00                	push   $0x0
  pushl $132
8010715a:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010715f:	e9 00 f5 ff ff       	jmp    80106664 <alltraps>

80107164 <vector133>:
.globl vector133
vector133:
  pushl $0
80107164:	6a 00                	push   $0x0
  pushl $133
80107166:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010716b:	e9 f4 f4 ff ff       	jmp    80106664 <alltraps>

80107170 <vector134>:
.globl vector134
vector134:
  pushl $0
80107170:	6a 00                	push   $0x0
  pushl $134
80107172:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107177:	e9 e8 f4 ff ff       	jmp    80106664 <alltraps>

8010717c <vector135>:
.globl vector135
vector135:
  pushl $0
8010717c:	6a 00                	push   $0x0
  pushl $135
8010717e:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107183:	e9 dc f4 ff ff       	jmp    80106664 <alltraps>

80107188 <vector136>:
.globl vector136
vector136:
  pushl $0
80107188:	6a 00                	push   $0x0
  pushl $136
8010718a:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010718f:	e9 d0 f4 ff ff       	jmp    80106664 <alltraps>

80107194 <vector137>:
.globl vector137
vector137:
  pushl $0
80107194:	6a 00                	push   $0x0
  pushl $137
80107196:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010719b:	e9 c4 f4 ff ff       	jmp    80106664 <alltraps>

801071a0 <vector138>:
.globl vector138
vector138:
  pushl $0
801071a0:	6a 00                	push   $0x0
  pushl $138
801071a2:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801071a7:	e9 b8 f4 ff ff       	jmp    80106664 <alltraps>

801071ac <vector139>:
.globl vector139
vector139:
  pushl $0
801071ac:	6a 00                	push   $0x0
  pushl $139
801071ae:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801071b3:	e9 ac f4 ff ff       	jmp    80106664 <alltraps>

801071b8 <vector140>:
.globl vector140
vector140:
  pushl $0
801071b8:	6a 00                	push   $0x0
  pushl $140
801071ba:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801071bf:	e9 a0 f4 ff ff       	jmp    80106664 <alltraps>

801071c4 <vector141>:
.globl vector141
vector141:
  pushl $0
801071c4:	6a 00                	push   $0x0
  pushl $141
801071c6:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801071cb:	e9 94 f4 ff ff       	jmp    80106664 <alltraps>

801071d0 <vector142>:
.globl vector142
vector142:
  pushl $0
801071d0:	6a 00                	push   $0x0
  pushl $142
801071d2:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801071d7:	e9 88 f4 ff ff       	jmp    80106664 <alltraps>

801071dc <vector143>:
.globl vector143
vector143:
  pushl $0
801071dc:	6a 00                	push   $0x0
  pushl $143
801071de:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801071e3:	e9 7c f4 ff ff       	jmp    80106664 <alltraps>

801071e8 <vector144>:
.globl vector144
vector144:
  pushl $0
801071e8:	6a 00                	push   $0x0
  pushl $144
801071ea:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801071ef:	e9 70 f4 ff ff       	jmp    80106664 <alltraps>

801071f4 <vector145>:
.globl vector145
vector145:
  pushl $0
801071f4:	6a 00                	push   $0x0
  pushl $145
801071f6:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801071fb:	e9 64 f4 ff ff       	jmp    80106664 <alltraps>

80107200 <vector146>:
.globl vector146
vector146:
  pushl $0
80107200:	6a 00                	push   $0x0
  pushl $146
80107202:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107207:	e9 58 f4 ff ff       	jmp    80106664 <alltraps>

8010720c <vector147>:
.globl vector147
vector147:
  pushl $0
8010720c:	6a 00                	push   $0x0
  pushl $147
8010720e:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107213:	e9 4c f4 ff ff       	jmp    80106664 <alltraps>

80107218 <vector148>:
.globl vector148
vector148:
  pushl $0
80107218:	6a 00                	push   $0x0
  pushl $148
8010721a:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010721f:	e9 40 f4 ff ff       	jmp    80106664 <alltraps>

80107224 <vector149>:
.globl vector149
vector149:
  pushl $0
80107224:	6a 00                	push   $0x0
  pushl $149
80107226:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010722b:	e9 34 f4 ff ff       	jmp    80106664 <alltraps>

80107230 <vector150>:
.globl vector150
vector150:
  pushl $0
80107230:	6a 00                	push   $0x0
  pushl $150
80107232:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107237:	e9 28 f4 ff ff       	jmp    80106664 <alltraps>

8010723c <vector151>:
.globl vector151
vector151:
  pushl $0
8010723c:	6a 00                	push   $0x0
  pushl $151
8010723e:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107243:	e9 1c f4 ff ff       	jmp    80106664 <alltraps>

80107248 <vector152>:
.globl vector152
vector152:
  pushl $0
80107248:	6a 00                	push   $0x0
  pushl $152
8010724a:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010724f:	e9 10 f4 ff ff       	jmp    80106664 <alltraps>

80107254 <vector153>:
.globl vector153
vector153:
  pushl $0
80107254:	6a 00                	push   $0x0
  pushl $153
80107256:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010725b:	e9 04 f4 ff ff       	jmp    80106664 <alltraps>

80107260 <vector154>:
.globl vector154
vector154:
  pushl $0
80107260:	6a 00                	push   $0x0
  pushl $154
80107262:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107267:	e9 f8 f3 ff ff       	jmp    80106664 <alltraps>

8010726c <vector155>:
.globl vector155
vector155:
  pushl $0
8010726c:	6a 00                	push   $0x0
  pushl $155
8010726e:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107273:	e9 ec f3 ff ff       	jmp    80106664 <alltraps>

80107278 <vector156>:
.globl vector156
vector156:
  pushl $0
80107278:	6a 00                	push   $0x0
  pushl $156
8010727a:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010727f:	e9 e0 f3 ff ff       	jmp    80106664 <alltraps>

80107284 <vector157>:
.globl vector157
vector157:
  pushl $0
80107284:	6a 00                	push   $0x0
  pushl $157
80107286:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010728b:	e9 d4 f3 ff ff       	jmp    80106664 <alltraps>

80107290 <vector158>:
.globl vector158
vector158:
  pushl $0
80107290:	6a 00                	push   $0x0
  pushl $158
80107292:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107297:	e9 c8 f3 ff ff       	jmp    80106664 <alltraps>

8010729c <vector159>:
.globl vector159
vector159:
  pushl $0
8010729c:	6a 00                	push   $0x0
  pushl $159
8010729e:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801072a3:	e9 bc f3 ff ff       	jmp    80106664 <alltraps>

801072a8 <vector160>:
.globl vector160
vector160:
  pushl $0
801072a8:	6a 00                	push   $0x0
  pushl $160
801072aa:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801072af:	e9 b0 f3 ff ff       	jmp    80106664 <alltraps>

801072b4 <vector161>:
.globl vector161
vector161:
  pushl $0
801072b4:	6a 00                	push   $0x0
  pushl $161
801072b6:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801072bb:	e9 a4 f3 ff ff       	jmp    80106664 <alltraps>

801072c0 <vector162>:
.globl vector162
vector162:
  pushl $0
801072c0:	6a 00                	push   $0x0
  pushl $162
801072c2:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801072c7:	e9 98 f3 ff ff       	jmp    80106664 <alltraps>

801072cc <vector163>:
.globl vector163
vector163:
  pushl $0
801072cc:	6a 00                	push   $0x0
  pushl $163
801072ce:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801072d3:	e9 8c f3 ff ff       	jmp    80106664 <alltraps>

801072d8 <vector164>:
.globl vector164
vector164:
  pushl $0
801072d8:	6a 00                	push   $0x0
  pushl $164
801072da:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801072df:	e9 80 f3 ff ff       	jmp    80106664 <alltraps>

801072e4 <vector165>:
.globl vector165
vector165:
  pushl $0
801072e4:	6a 00                	push   $0x0
  pushl $165
801072e6:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801072eb:	e9 74 f3 ff ff       	jmp    80106664 <alltraps>

801072f0 <vector166>:
.globl vector166
vector166:
  pushl $0
801072f0:	6a 00                	push   $0x0
  pushl $166
801072f2:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801072f7:	e9 68 f3 ff ff       	jmp    80106664 <alltraps>

801072fc <vector167>:
.globl vector167
vector167:
  pushl $0
801072fc:	6a 00                	push   $0x0
  pushl $167
801072fe:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107303:	e9 5c f3 ff ff       	jmp    80106664 <alltraps>

80107308 <vector168>:
.globl vector168
vector168:
  pushl $0
80107308:	6a 00                	push   $0x0
  pushl $168
8010730a:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010730f:	e9 50 f3 ff ff       	jmp    80106664 <alltraps>

80107314 <vector169>:
.globl vector169
vector169:
  pushl $0
80107314:	6a 00                	push   $0x0
  pushl $169
80107316:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
8010731b:	e9 44 f3 ff ff       	jmp    80106664 <alltraps>

80107320 <vector170>:
.globl vector170
vector170:
  pushl $0
80107320:	6a 00                	push   $0x0
  pushl $170
80107322:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107327:	e9 38 f3 ff ff       	jmp    80106664 <alltraps>

8010732c <vector171>:
.globl vector171
vector171:
  pushl $0
8010732c:	6a 00                	push   $0x0
  pushl $171
8010732e:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107333:	e9 2c f3 ff ff       	jmp    80106664 <alltraps>

80107338 <vector172>:
.globl vector172
vector172:
  pushl $0
80107338:	6a 00                	push   $0x0
  pushl $172
8010733a:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010733f:	e9 20 f3 ff ff       	jmp    80106664 <alltraps>

80107344 <vector173>:
.globl vector173
vector173:
  pushl $0
80107344:	6a 00                	push   $0x0
  pushl $173
80107346:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010734b:	e9 14 f3 ff ff       	jmp    80106664 <alltraps>

80107350 <vector174>:
.globl vector174
vector174:
  pushl $0
80107350:	6a 00                	push   $0x0
  pushl $174
80107352:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107357:	e9 08 f3 ff ff       	jmp    80106664 <alltraps>

8010735c <vector175>:
.globl vector175
vector175:
  pushl $0
8010735c:	6a 00                	push   $0x0
  pushl $175
8010735e:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107363:	e9 fc f2 ff ff       	jmp    80106664 <alltraps>

80107368 <vector176>:
.globl vector176
vector176:
  pushl $0
80107368:	6a 00                	push   $0x0
  pushl $176
8010736a:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010736f:	e9 f0 f2 ff ff       	jmp    80106664 <alltraps>

80107374 <vector177>:
.globl vector177
vector177:
  pushl $0
80107374:	6a 00                	push   $0x0
  pushl $177
80107376:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010737b:	e9 e4 f2 ff ff       	jmp    80106664 <alltraps>

80107380 <vector178>:
.globl vector178
vector178:
  pushl $0
80107380:	6a 00                	push   $0x0
  pushl $178
80107382:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107387:	e9 d8 f2 ff ff       	jmp    80106664 <alltraps>

8010738c <vector179>:
.globl vector179
vector179:
  pushl $0
8010738c:	6a 00                	push   $0x0
  pushl $179
8010738e:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107393:	e9 cc f2 ff ff       	jmp    80106664 <alltraps>

80107398 <vector180>:
.globl vector180
vector180:
  pushl $0
80107398:	6a 00                	push   $0x0
  pushl $180
8010739a:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010739f:	e9 c0 f2 ff ff       	jmp    80106664 <alltraps>

801073a4 <vector181>:
.globl vector181
vector181:
  pushl $0
801073a4:	6a 00                	push   $0x0
  pushl $181
801073a6:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801073ab:	e9 b4 f2 ff ff       	jmp    80106664 <alltraps>

801073b0 <vector182>:
.globl vector182
vector182:
  pushl $0
801073b0:	6a 00                	push   $0x0
  pushl $182
801073b2:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801073b7:	e9 a8 f2 ff ff       	jmp    80106664 <alltraps>

801073bc <vector183>:
.globl vector183
vector183:
  pushl $0
801073bc:	6a 00                	push   $0x0
  pushl $183
801073be:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801073c3:	e9 9c f2 ff ff       	jmp    80106664 <alltraps>

801073c8 <vector184>:
.globl vector184
vector184:
  pushl $0
801073c8:	6a 00                	push   $0x0
  pushl $184
801073ca:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801073cf:	e9 90 f2 ff ff       	jmp    80106664 <alltraps>

801073d4 <vector185>:
.globl vector185
vector185:
  pushl $0
801073d4:	6a 00                	push   $0x0
  pushl $185
801073d6:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801073db:	e9 84 f2 ff ff       	jmp    80106664 <alltraps>

801073e0 <vector186>:
.globl vector186
vector186:
  pushl $0
801073e0:	6a 00                	push   $0x0
  pushl $186
801073e2:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801073e7:	e9 78 f2 ff ff       	jmp    80106664 <alltraps>

801073ec <vector187>:
.globl vector187
vector187:
  pushl $0
801073ec:	6a 00                	push   $0x0
  pushl $187
801073ee:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801073f3:	e9 6c f2 ff ff       	jmp    80106664 <alltraps>

801073f8 <vector188>:
.globl vector188
vector188:
  pushl $0
801073f8:	6a 00                	push   $0x0
  pushl $188
801073fa:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801073ff:	e9 60 f2 ff ff       	jmp    80106664 <alltraps>

80107404 <vector189>:
.globl vector189
vector189:
  pushl $0
80107404:	6a 00                	push   $0x0
  pushl $189
80107406:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010740b:	e9 54 f2 ff ff       	jmp    80106664 <alltraps>

80107410 <vector190>:
.globl vector190
vector190:
  pushl $0
80107410:	6a 00                	push   $0x0
  pushl $190
80107412:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107417:	e9 48 f2 ff ff       	jmp    80106664 <alltraps>

8010741c <vector191>:
.globl vector191
vector191:
  pushl $0
8010741c:	6a 00                	push   $0x0
  pushl $191
8010741e:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107423:	e9 3c f2 ff ff       	jmp    80106664 <alltraps>

80107428 <vector192>:
.globl vector192
vector192:
  pushl $0
80107428:	6a 00                	push   $0x0
  pushl $192
8010742a:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010742f:	e9 30 f2 ff ff       	jmp    80106664 <alltraps>

80107434 <vector193>:
.globl vector193
vector193:
  pushl $0
80107434:	6a 00                	push   $0x0
  pushl $193
80107436:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010743b:	e9 24 f2 ff ff       	jmp    80106664 <alltraps>

80107440 <vector194>:
.globl vector194
vector194:
  pushl $0
80107440:	6a 00                	push   $0x0
  pushl $194
80107442:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107447:	e9 18 f2 ff ff       	jmp    80106664 <alltraps>

8010744c <vector195>:
.globl vector195
vector195:
  pushl $0
8010744c:	6a 00                	push   $0x0
  pushl $195
8010744e:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107453:	e9 0c f2 ff ff       	jmp    80106664 <alltraps>

80107458 <vector196>:
.globl vector196
vector196:
  pushl $0
80107458:	6a 00                	push   $0x0
  pushl $196
8010745a:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010745f:	e9 00 f2 ff ff       	jmp    80106664 <alltraps>

80107464 <vector197>:
.globl vector197
vector197:
  pushl $0
80107464:	6a 00                	push   $0x0
  pushl $197
80107466:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010746b:	e9 f4 f1 ff ff       	jmp    80106664 <alltraps>

80107470 <vector198>:
.globl vector198
vector198:
  pushl $0
80107470:	6a 00                	push   $0x0
  pushl $198
80107472:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107477:	e9 e8 f1 ff ff       	jmp    80106664 <alltraps>

8010747c <vector199>:
.globl vector199
vector199:
  pushl $0
8010747c:	6a 00                	push   $0x0
  pushl $199
8010747e:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107483:	e9 dc f1 ff ff       	jmp    80106664 <alltraps>

80107488 <vector200>:
.globl vector200
vector200:
  pushl $0
80107488:	6a 00                	push   $0x0
  pushl $200
8010748a:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010748f:	e9 d0 f1 ff ff       	jmp    80106664 <alltraps>

80107494 <vector201>:
.globl vector201
vector201:
  pushl $0
80107494:	6a 00                	push   $0x0
  pushl $201
80107496:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010749b:	e9 c4 f1 ff ff       	jmp    80106664 <alltraps>

801074a0 <vector202>:
.globl vector202
vector202:
  pushl $0
801074a0:	6a 00                	push   $0x0
  pushl $202
801074a2:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801074a7:	e9 b8 f1 ff ff       	jmp    80106664 <alltraps>

801074ac <vector203>:
.globl vector203
vector203:
  pushl $0
801074ac:	6a 00                	push   $0x0
  pushl $203
801074ae:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801074b3:	e9 ac f1 ff ff       	jmp    80106664 <alltraps>

801074b8 <vector204>:
.globl vector204
vector204:
  pushl $0
801074b8:	6a 00                	push   $0x0
  pushl $204
801074ba:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801074bf:	e9 a0 f1 ff ff       	jmp    80106664 <alltraps>

801074c4 <vector205>:
.globl vector205
vector205:
  pushl $0
801074c4:	6a 00                	push   $0x0
  pushl $205
801074c6:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801074cb:	e9 94 f1 ff ff       	jmp    80106664 <alltraps>

801074d0 <vector206>:
.globl vector206
vector206:
  pushl $0
801074d0:	6a 00                	push   $0x0
  pushl $206
801074d2:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801074d7:	e9 88 f1 ff ff       	jmp    80106664 <alltraps>

801074dc <vector207>:
.globl vector207
vector207:
  pushl $0
801074dc:	6a 00                	push   $0x0
  pushl $207
801074de:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801074e3:	e9 7c f1 ff ff       	jmp    80106664 <alltraps>

801074e8 <vector208>:
.globl vector208
vector208:
  pushl $0
801074e8:	6a 00                	push   $0x0
  pushl $208
801074ea:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801074ef:	e9 70 f1 ff ff       	jmp    80106664 <alltraps>

801074f4 <vector209>:
.globl vector209
vector209:
  pushl $0
801074f4:	6a 00                	push   $0x0
  pushl $209
801074f6:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801074fb:	e9 64 f1 ff ff       	jmp    80106664 <alltraps>

80107500 <vector210>:
.globl vector210
vector210:
  pushl $0
80107500:	6a 00                	push   $0x0
  pushl $210
80107502:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107507:	e9 58 f1 ff ff       	jmp    80106664 <alltraps>

8010750c <vector211>:
.globl vector211
vector211:
  pushl $0
8010750c:	6a 00                	push   $0x0
  pushl $211
8010750e:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107513:	e9 4c f1 ff ff       	jmp    80106664 <alltraps>

80107518 <vector212>:
.globl vector212
vector212:
  pushl $0
80107518:	6a 00                	push   $0x0
  pushl $212
8010751a:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010751f:	e9 40 f1 ff ff       	jmp    80106664 <alltraps>

80107524 <vector213>:
.globl vector213
vector213:
  pushl $0
80107524:	6a 00                	push   $0x0
  pushl $213
80107526:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010752b:	e9 34 f1 ff ff       	jmp    80106664 <alltraps>

80107530 <vector214>:
.globl vector214
vector214:
  pushl $0
80107530:	6a 00                	push   $0x0
  pushl $214
80107532:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107537:	e9 28 f1 ff ff       	jmp    80106664 <alltraps>

8010753c <vector215>:
.globl vector215
vector215:
  pushl $0
8010753c:	6a 00                	push   $0x0
  pushl $215
8010753e:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107543:	e9 1c f1 ff ff       	jmp    80106664 <alltraps>

80107548 <vector216>:
.globl vector216
vector216:
  pushl $0
80107548:	6a 00                	push   $0x0
  pushl $216
8010754a:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010754f:	e9 10 f1 ff ff       	jmp    80106664 <alltraps>

80107554 <vector217>:
.globl vector217
vector217:
  pushl $0
80107554:	6a 00                	push   $0x0
  pushl $217
80107556:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010755b:	e9 04 f1 ff ff       	jmp    80106664 <alltraps>

80107560 <vector218>:
.globl vector218
vector218:
  pushl $0
80107560:	6a 00                	push   $0x0
  pushl $218
80107562:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107567:	e9 f8 f0 ff ff       	jmp    80106664 <alltraps>

8010756c <vector219>:
.globl vector219
vector219:
  pushl $0
8010756c:	6a 00                	push   $0x0
  pushl $219
8010756e:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107573:	e9 ec f0 ff ff       	jmp    80106664 <alltraps>

80107578 <vector220>:
.globl vector220
vector220:
  pushl $0
80107578:	6a 00                	push   $0x0
  pushl $220
8010757a:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010757f:	e9 e0 f0 ff ff       	jmp    80106664 <alltraps>

80107584 <vector221>:
.globl vector221
vector221:
  pushl $0
80107584:	6a 00                	push   $0x0
  pushl $221
80107586:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010758b:	e9 d4 f0 ff ff       	jmp    80106664 <alltraps>

80107590 <vector222>:
.globl vector222
vector222:
  pushl $0
80107590:	6a 00                	push   $0x0
  pushl $222
80107592:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107597:	e9 c8 f0 ff ff       	jmp    80106664 <alltraps>

8010759c <vector223>:
.globl vector223
vector223:
  pushl $0
8010759c:	6a 00                	push   $0x0
  pushl $223
8010759e:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801075a3:	e9 bc f0 ff ff       	jmp    80106664 <alltraps>

801075a8 <vector224>:
.globl vector224
vector224:
  pushl $0
801075a8:	6a 00                	push   $0x0
  pushl $224
801075aa:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801075af:	e9 b0 f0 ff ff       	jmp    80106664 <alltraps>

801075b4 <vector225>:
.globl vector225
vector225:
  pushl $0
801075b4:	6a 00                	push   $0x0
  pushl $225
801075b6:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801075bb:	e9 a4 f0 ff ff       	jmp    80106664 <alltraps>

801075c0 <vector226>:
.globl vector226
vector226:
  pushl $0
801075c0:	6a 00                	push   $0x0
  pushl $226
801075c2:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801075c7:	e9 98 f0 ff ff       	jmp    80106664 <alltraps>

801075cc <vector227>:
.globl vector227
vector227:
  pushl $0
801075cc:	6a 00                	push   $0x0
  pushl $227
801075ce:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801075d3:	e9 8c f0 ff ff       	jmp    80106664 <alltraps>

801075d8 <vector228>:
.globl vector228
vector228:
  pushl $0
801075d8:	6a 00                	push   $0x0
  pushl $228
801075da:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801075df:	e9 80 f0 ff ff       	jmp    80106664 <alltraps>

801075e4 <vector229>:
.globl vector229
vector229:
  pushl $0
801075e4:	6a 00                	push   $0x0
  pushl $229
801075e6:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801075eb:	e9 74 f0 ff ff       	jmp    80106664 <alltraps>

801075f0 <vector230>:
.globl vector230
vector230:
  pushl $0
801075f0:	6a 00                	push   $0x0
  pushl $230
801075f2:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801075f7:	e9 68 f0 ff ff       	jmp    80106664 <alltraps>

801075fc <vector231>:
.globl vector231
vector231:
  pushl $0
801075fc:	6a 00                	push   $0x0
  pushl $231
801075fe:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107603:	e9 5c f0 ff ff       	jmp    80106664 <alltraps>

80107608 <vector232>:
.globl vector232
vector232:
  pushl $0
80107608:	6a 00                	push   $0x0
  pushl $232
8010760a:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010760f:	e9 50 f0 ff ff       	jmp    80106664 <alltraps>

80107614 <vector233>:
.globl vector233
vector233:
  pushl $0
80107614:	6a 00                	push   $0x0
  pushl $233
80107616:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010761b:	e9 44 f0 ff ff       	jmp    80106664 <alltraps>

80107620 <vector234>:
.globl vector234
vector234:
  pushl $0
80107620:	6a 00                	push   $0x0
  pushl $234
80107622:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107627:	e9 38 f0 ff ff       	jmp    80106664 <alltraps>

8010762c <vector235>:
.globl vector235
vector235:
  pushl $0
8010762c:	6a 00                	push   $0x0
  pushl $235
8010762e:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107633:	e9 2c f0 ff ff       	jmp    80106664 <alltraps>

80107638 <vector236>:
.globl vector236
vector236:
  pushl $0
80107638:	6a 00                	push   $0x0
  pushl $236
8010763a:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010763f:	e9 20 f0 ff ff       	jmp    80106664 <alltraps>

80107644 <vector237>:
.globl vector237
vector237:
  pushl $0
80107644:	6a 00                	push   $0x0
  pushl $237
80107646:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010764b:	e9 14 f0 ff ff       	jmp    80106664 <alltraps>

80107650 <vector238>:
.globl vector238
vector238:
  pushl $0
80107650:	6a 00                	push   $0x0
  pushl $238
80107652:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107657:	e9 08 f0 ff ff       	jmp    80106664 <alltraps>

8010765c <vector239>:
.globl vector239
vector239:
  pushl $0
8010765c:	6a 00                	push   $0x0
  pushl $239
8010765e:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107663:	e9 fc ef ff ff       	jmp    80106664 <alltraps>

80107668 <vector240>:
.globl vector240
vector240:
  pushl $0
80107668:	6a 00                	push   $0x0
  pushl $240
8010766a:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010766f:	e9 f0 ef ff ff       	jmp    80106664 <alltraps>

80107674 <vector241>:
.globl vector241
vector241:
  pushl $0
80107674:	6a 00                	push   $0x0
  pushl $241
80107676:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010767b:	e9 e4 ef ff ff       	jmp    80106664 <alltraps>

80107680 <vector242>:
.globl vector242
vector242:
  pushl $0
80107680:	6a 00                	push   $0x0
  pushl $242
80107682:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107687:	e9 d8 ef ff ff       	jmp    80106664 <alltraps>

8010768c <vector243>:
.globl vector243
vector243:
  pushl $0
8010768c:	6a 00                	push   $0x0
  pushl $243
8010768e:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107693:	e9 cc ef ff ff       	jmp    80106664 <alltraps>

80107698 <vector244>:
.globl vector244
vector244:
  pushl $0
80107698:	6a 00                	push   $0x0
  pushl $244
8010769a:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010769f:	e9 c0 ef ff ff       	jmp    80106664 <alltraps>

801076a4 <vector245>:
.globl vector245
vector245:
  pushl $0
801076a4:	6a 00                	push   $0x0
  pushl $245
801076a6:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801076ab:	e9 b4 ef ff ff       	jmp    80106664 <alltraps>

801076b0 <vector246>:
.globl vector246
vector246:
  pushl $0
801076b0:	6a 00                	push   $0x0
  pushl $246
801076b2:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801076b7:	e9 a8 ef ff ff       	jmp    80106664 <alltraps>

801076bc <vector247>:
.globl vector247
vector247:
  pushl $0
801076bc:	6a 00                	push   $0x0
  pushl $247
801076be:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801076c3:	e9 9c ef ff ff       	jmp    80106664 <alltraps>

801076c8 <vector248>:
.globl vector248
vector248:
  pushl $0
801076c8:	6a 00                	push   $0x0
  pushl $248
801076ca:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801076cf:	e9 90 ef ff ff       	jmp    80106664 <alltraps>

801076d4 <vector249>:
.globl vector249
vector249:
  pushl $0
801076d4:	6a 00                	push   $0x0
  pushl $249
801076d6:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801076db:	e9 84 ef ff ff       	jmp    80106664 <alltraps>

801076e0 <vector250>:
.globl vector250
vector250:
  pushl $0
801076e0:	6a 00                	push   $0x0
  pushl $250
801076e2:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801076e7:	e9 78 ef ff ff       	jmp    80106664 <alltraps>

801076ec <vector251>:
.globl vector251
vector251:
  pushl $0
801076ec:	6a 00                	push   $0x0
  pushl $251
801076ee:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801076f3:	e9 6c ef ff ff       	jmp    80106664 <alltraps>

801076f8 <vector252>:
.globl vector252
vector252:
  pushl $0
801076f8:	6a 00                	push   $0x0
  pushl $252
801076fa:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801076ff:	e9 60 ef ff ff       	jmp    80106664 <alltraps>

80107704 <vector253>:
.globl vector253
vector253:
  pushl $0
80107704:	6a 00                	push   $0x0
  pushl $253
80107706:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010770b:	e9 54 ef ff ff       	jmp    80106664 <alltraps>

80107710 <vector254>:
.globl vector254
vector254:
  pushl $0
80107710:	6a 00                	push   $0x0
  pushl $254
80107712:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107717:	e9 48 ef ff ff       	jmp    80106664 <alltraps>

8010771c <vector255>:
.globl vector255
vector255:
  pushl $0
8010771c:	6a 00                	push   $0x0
  pushl $255
8010771e:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107723:	e9 3c ef ff ff       	jmp    80106664 <alltraps>

80107728 <lgdt>:
{
80107728:	55                   	push   %ebp
80107729:	89 e5                	mov    %esp,%ebp
8010772b:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010772e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107731:	83 e8 01             	sub    $0x1,%eax
80107734:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107738:	8b 45 08             	mov    0x8(%ebp),%eax
8010773b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010773f:	8b 45 08             	mov    0x8(%ebp),%eax
80107742:	c1 e8 10             	shr    $0x10,%eax
80107745:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107749:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010774c:	0f 01 10             	lgdtl  (%eax)
}
8010774f:	90                   	nop
80107750:	c9                   	leave
80107751:	c3                   	ret

80107752 <ltr>:
{
80107752:	55                   	push   %ebp
80107753:	89 e5                	mov    %esp,%ebp
80107755:	83 ec 04             	sub    $0x4,%esp
80107758:	8b 45 08             	mov    0x8(%ebp),%eax
8010775b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010775f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107763:	0f 00 d8             	ltr    %eax
}
80107766:	90                   	nop
80107767:	c9                   	leave
80107768:	c3                   	ret

80107769 <loadgs>:
{
80107769:	55                   	push   %ebp
8010776a:	89 e5                	mov    %esp,%ebp
8010776c:	83 ec 04             	sub    $0x4,%esp
8010776f:	8b 45 08             	mov    0x8(%ebp),%eax
80107772:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107776:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010777a:	8e e8                	mov    %eax,%gs
}
8010777c:	90                   	nop
8010777d:	c9                   	leave
8010777e:	c3                   	ret

8010777f <lcr3>:
{
8010777f:	55                   	push   %ebp
80107780:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107782:	8b 45 08             	mov    0x8(%ebp),%eax
80107785:	0f 22 d8             	mov    %eax,%cr3
}
80107788:	90                   	nop
80107789:	5d                   	pop    %ebp
8010778a:	c3                   	ret

8010778b <v2p>:
static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
8010778b:	55                   	push   %ebp
8010778c:	89 e5                	mov    %esp,%ebp
8010778e:	8b 45 08             	mov    0x8(%ebp),%eax
80107791:	05 00 00 00 80       	add    $0x80000000,%eax
80107796:	5d                   	pop    %ebp
80107797:	c3                   	ret

80107798 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80107798:	55                   	push   %ebp
80107799:	89 e5                	mov    %esp,%ebp
8010779b:	8b 45 08             	mov    0x8(%ebp),%eax
8010779e:	05 00 00 00 80       	add    $0x80000000,%eax
801077a3:	5d                   	pop    %ebp
801077a4:	c3                   	ret

801077a5 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801077a5:	55                   	push   %ebp
801077a6:	89 e5                	mov    %esp,%ebp
801077a8:	53                   	push   %ebx
801077a9:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801077ac:	e8 2c b8 ff ff       	call   80102fdd <cpunum>
801077b1:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801077b7:	05 20 13 11 80       	add    $0x80111320,%eax
801077bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801077bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077c2:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801077c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077cb:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801077d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077d4:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801077d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077db:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801077df:	83 e2 f0             	and    $0xfffffff0,%edx
801077e2:	83 ca 0a             	or     $0xa,%edx
801077e5:	88 50 7d             	mov    %dl,0x7d(%eax)
801077e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077eb:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801077ef:	83 ca 10             	or     $0x10,%edx
801077f2:	88 50 7d             	mov    %dl,0x7d(%eax)
801077f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077f8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801077fc:	83 e2 9f             	and    $0xffffff9f,%edx
801077ff:	88 50 7d             	mov    %dl,0x7d(%eax)
80107802:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107805:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107809:	83 ca 80             	or     $0xffffff80,%edx
8010780c:	88 50 7d             	mov    %dl,0x7d(%eax)
8010780f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107812:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107816:	83 ca 0f             	or     $0xf,%edx
80107819:	88 50 7e             	mov    %dl,0x7e(%eax)
8010781c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010781f:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107823:	83 e2 ef             	and    $0xffffffef,%edx
80107826:	88 50 7e             	mov    %dl,0x7e(%eax)
80107829:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010782c:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107830:	83 e2 df             	and    $0xffffffdf,%edx
80107833:	88 50 7e             	mov    %dl,0x7e(%eax)
80107836:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107839:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010783d:	83 ca 40             	or     $0x40,%edx
80107840:	88 50 7e             	mov    %dl,0x7e(%eax)
80107843:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107846:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010784a:	83 ca 80             	or     $0xffffff80,%edx
8010784d:	88 50 7e             	mov    %dl,0x7e(%eax)
80107850:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107853:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107857:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010785a:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107861:	ff ff 
80107863:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107866:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010786d:	00 00 
8010786f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107872:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107879:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010787c:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107883:	83 e2 f0             	and    $0xfffffff0,%edx
80107886:	83 ca 02             	or     $0x2,%edx
80107889:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010788f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107892:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107899:	83 ca 10             	or     $0x10,%edx
8010789c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a5:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078ac:	83 e2 9f             	and    $0xffffff9f,%edx
801078af:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b8:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
801078bf:	83 ca 80             	or     $0xffffff80,%edx
801078c2:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801078c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078cb:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801078d2:	83 ca 0f             	or     $0xf,%edx
801078d5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078de:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801078e5:	83 e2 ef             	and    $0xffffffef,%edx
801078e8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801078ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f1:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801078f8:	83 e2 df             	and    $0xffffffdf,%edx
801078fb:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107901:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107904:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010790b:	83 ca 40             	or     $0x40,%edx
8010790e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107914:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107917:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
8010791e:	83 ca 80             	or     $0xffffff80,%edx
80107921:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107927:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010792a:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107931:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107934:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010793b:	ff ff 
8010793d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107940:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107947:	00 00 
80107949:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010794c:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107956:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010795d:	83 e2 f0             	and    $0xfffffff0,%edx
80107960:	83 ca 0a             	or     $0xa,%edx
80107963:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107969:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010796c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107973:	83 ca 10             	or     $0x10,%edx
80107976:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010797c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010797f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107986:	83 ca 60             	or     $0x60,%edx
80107989:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010798f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107992:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107999:	83 ca 80             	or     $0xffffff80,%edx
8010799c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801079a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079a5:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801079ac:	83 ca 0f             	or     $0xf,%edx
801079af:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801079b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079b8:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801079bf:	83 e2 ef             	and    $0xffffffef,%edx
801079c2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801079c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079cb:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801079d2:	83 e2 df             	and    $0xffffffdf,%edx
801079d5:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801079db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079de:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801079e5:	83 ca 40             	or     $0x40,%edx
801079e8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801079ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f1:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801079f8:	83 ca 80             	or     $0xffffff80,%edx
801079fb:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a04:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a0e:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107a15:	ff ff 
80107a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1a:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107a21:	00 00 
80107a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a26:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107a2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a30:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a37:	83 e2 f0             	and    $0xfffffff0,%edx
80107a3a:	83 ca 02             	or     $0x2,%edx
80107a3d:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a46:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a4d:	83 ca 10             	or     $0x10,%edx
80107a50:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a59:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a60:	83 ca 60             	or     $0x60,%edx
80107a63:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107a69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107a73:	83 ca 80             	or     $0xffffff80,%edx
80107a76:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107a7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7f:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107a86:	83 ca 0f             	or     $0xf,%edx
80107a89:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107a8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a92:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107a99:	83 e2 ef             	and    $0xffffffef,%edx
80107a9c:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aa5:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107aac:	83 e2 df             	and    $0xffffffdf,%edx
80107aaf:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107ab5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab8:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107abf:	83 ca 40             	or     $0x40,%edx
80107ac2:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107acb:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107ad2:	83 ca 80             	or     $0xffffff80,%edx
80107ad5:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107adb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ade:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107ae5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae8:	05 b4 00 00 00       	add    $0xb4,%eax
80107aed:	89 c3                	mov    %eax,%ebx
80107aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af2:	05 b4 00 00 00       	add    $0xb4,%eax
80107af7:	c1 e8 10             	shr    $0x10,%eax
80107afa:	89 c2                	mov    %eax,%edx
80107afc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aff:	05 b4 00 00 00       	add    $0xb4,%eax
80107b04:	c1 e8 18             	shr    $0x18,%eax
80107b07:	89 c1                	mov    %eax,%ecx
80107b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0c:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107b13:	00 00 
80107b15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b18:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b22:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80107b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b2b:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107b32:	83 e2 f0             	and    $0xfffffff0,%edx
80107b35:	83 ca 02             	or     $0x2,%edx
80107b38:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b41:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107b48:	83 ca 10             	or     $0x10,%edx
80107b4b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b54:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107b5b:	83 e2 9f             	and    $0xffffff9f,%edx
80107b5e:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b67:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107b6e:	83 ca 80             	or     $0xffffff80,%edx
80107b71:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107b77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107b81:	83 e2 f0             	and    $0xfffffff0,%edx
80107b84:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107b94:	83 e2 ef             	and    $0xffffffef,%edx
80107b97:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba0:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107ba7:	83 e2 df             	and    $0xffffffdf,%edx
80107baa:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107bb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb3:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107bba:	83 ca 40             	or     $0x40,%edx
80107bbd:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc6:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107bcd:	83 ca 80             	or     $0xffffff80,%edx
80107bd0:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107bd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd9:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107bdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be2:	83 c0 70             	add    $0x70,%eax
80107be5:	83 ec 08             	sub    $0x8,%esp
80107be8:	6a 38                	push   $0x38
80107bea:	50                   	push   %eax
80107beb:	e8 38 fb ff ff       	call   80107728 <lgdt>
80107bf0:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80107bf3:	83 ec 0c             	sub    $0xc,%esp
80107bf6:	6a 18                	push   $0x18
80107bf8:	e8 6c fb ff ff       	call   80107769 <loadgs>
80107bfd:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80107c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c03:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107c09:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107c10:	00 00 00 00 
}
80107c14:	90                   	nop
80107c15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107c18:	c9                   	leave
80107c19:	c3                   	ret

80107c1a <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107c1a:	55                   	push   %ebp
80107c1b:	89 e5                	mov    %esp,%ebp
80107c1d:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107c20:	8b 45 0c             	mov    0xc(%ebp),%eax
80107c23:	c1 e8 16             	shr    $0x16,%eax
80107c26:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107c2d:	8b 45 08             	mov    0x8(%ebp),%eax
80107c30:	01 d0                	add    %edx,%eax
80107c32:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107c35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c38:	8b 00                	mov    (%eax),%eax
80107c3a:	83 e0 01             	and    $0x1,%eax
80107c3d:	85 c0                	test   %eax,%eax
80107c3f:	74 18                	je     80107c59 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107c41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c44:	8b 00                	mov    (%eax),%eax
80107c46:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107c4b:	50                   	push   %eax
80107c4c:	e8 47 fb ff ff       	call   80107798 <p2v>
80107c51:	83 c4 04             	add    $0x4,%esp
80107c54:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107c57:	eb 48                	jmp    80107ca1 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107c59:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107c5d:	74 0e                	je     80107c6d <walkpgdir+0x53>
80107c5f:	e8 15 b0 ff ff       	call   80102c79 <kalloc>
80107c64:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107c67:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107c6b:	75 07                	jne    80107c74 <walkpgdir+0x5a>
      return 0;
80107c6d:	b8 00 00 00 00       	mov    $0x0,%eax
80107c72:	eb 44                	jmp    80107cb8 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107c74:	83 ec 04             	sub    $0x4,%esp
80107c77:	68 00 10 00 00       	push   $0x1000
80107c7c:	6a 00                	push   $0x0
80107c7e:	ff 75 f4             	push   -0xc(%ebp)
80107c81:	e8 23 d6 ff ff       	call   801052a9 <memset>
80107c86:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107c89:	83 ec 0c             	sub    $0xc,%esp
80107c8c:	ff 75 f4             	push   -0xc(%ebp)
80107c8f:	e8 f7 fa ff ff       	call   8010778b <v2p>
80107c94:	83 c4 10             	add    $0x10,%esp
80107c97:	83 c8 07             	or     $0x7,%eax
80107c9a:	89 c2                	mov    %eax,%edx
80107c9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c9f:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107ca1:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ca4:	c1 e8 0c             	shr    $0xc,%eax
80107ca7:	25 ff 03 00 00       	and    $0x3ff,%eax
80107cac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb6:	01 d0                	add    %edx,%eax
}
80107cb8:	c9                   	leave
80107cb9:	c3                   	ret

80107cba <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107cba:	55                   	push   %ebp
80107cbb:	89 e5                	mov    %esp,%ebp
80107cbd:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107cc0:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cc3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107cc8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107ccb:	8b 55 0c             	mov    0xc(%ebp),%edx
80107cce:	8b 45 10             	mov    0x10(%ebp),%eax
80107cd1:	01 d0                	add    %edx,%eax
80107cd3:	83 e8 01             	sub    $0x1,%eax
80107cd6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107cdb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107cde:	83 ec 04             	sub    $0x4,%esp
80107ce1:	6a 01                	push   $0x1
80107ce3:	ff 75 f4             	push   -0xc(%ebp)
80107ce6:	ff 75 08             	push   0x8(%ebp)
80107ce9:	e8 2c ff ff ff       	call   80107c1a <walkpgdir>
80107cee:	83 c4 10             	add    $0x10,%esp
80107cf1:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107cf4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107cf8:	75 07                	jne    80107d01 <mappages+0x47>
      return -1;
80107cfa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107cff:	eb 47                	jmp    80107d48 <mappages+0x8e>
    if(*pte & PTE_P)
80107d01:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d04:	8b 00                	mov    (%eax),%eax
80107d06:	83 e0 01             	and    $0x1,%eax
80107d09:	85 c0                	test   %eax,%eax
80107d0b:	74 0d                	je     80107d1a <mappages+0x60>
      panic("remap");
80107d0d:	83 ec 0c             	sub    $0xc,%esp
80107d10:	68 58 8b 10 80       	push   $0x80108b58
80107d15:	e8 5f 88 ff ff       	call   80100579 <panic>
    *pte = pa | perm | PTE_P;
80107d1a:	8b 45 18             	mov    0x18(%ebp),%eax
80107d1d:	0b 45 14             	or     0x14(%ebp),%eax
80107d20:	83 c8 01             	or     $0x1,%eax
80107d23:	89 c2                	mov    %eax,%edx
80107d25:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107d28:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107d2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107d30:	74 10                	je     80107d42 <mappages+0x88>
      break;
    a += PGSIZE;
80107d32:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107d39:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107d40:	eb 9c                	jmp    80107cde <mappages+0x24>
      break;
80107d42:	90                   	nop
  }
  return 0;
80107d43:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107d48:	c9                   	leave
80107d49:	c3                   	ret

80107d4a <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107d4a:	55                   	push   %ebp
80107d4b:	89 e5                	mov    %esp,%ebp
80107d4d:	53                   	push   %ebx
80107d4e:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107d51:	e8 23 af ff ff       	call   80102c79 <kalloc>
80107d56:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107d59:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107d5d:	75 0a                	jne    80107d69 <setupkvm+0x1f>
    return 0;
80107d5f:	b8 00 00 00 00       	mov    $0x0,%eax
80107d64:	e9 8e 00 00 00       	jmp    80107df7 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80107d69:	83 ec 04             	sub    $0x4,%esp
80107d6c:	68 00 10 00 00       	push   $0x1000
80107d71:	6a 00                	push   $0x0
80107d73:	ff 75 f0             	push   -0x10(%ebp)
80107d76:	e8 2e d5 ff ff       	call   801052a9 <memset>
80107d7b:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107d7e:	83 ec 0c             	sub    $0xc,%esp
80107d81:	68 00 00 00 0e       	push   $0xe000000
80107d86:	e8 0d fa ff ff       	call   80107798 <p2v>
80107d8b:	83 c4 10             	add    $0x10,%esp
80107d8e:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107d93:	76 0d                	jbe    80107da2 <setupkvm+0x58>
    panic("PHYSTOP too high");
80107d95:	83 ec 0c             	sub    $0xc,%esp
80107d98:	68 5e 8b 10 80       	push   $0x80108b5e
80107d9d:	e8 d7 87 ff ff       	call   80100579 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107da2:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107da9:	eb 40                	jmp    80107deb <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dae:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80107db1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db4:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dba:	8b 58 08             	mov    0x8(%eax),%ebx
80107dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc0:	8b 40 04             	mov    0x4(%eax),%eax
80107dc3:	29 c3                	sub    %eax,%ebx
80107dc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc8:	8b 00                	mov    (%eax),%eax
80107dca:	83 ec 0c             	sub    $0xc,%esp
80107dcd:	51                   	push   %ecx
80107dce:	52                   	push   %edx
80107dcf:	53                   	push   %ebx
80107dd0:	50                   	push   %eax
80107dd1:	ff 75 f0             	push   -0x10(%ebp)
80107dd4:	e8 e1 fe ff ff       	call   80107cba <mappages>
80107dd9:	83 c4 20             	add    $0x20,%esp
80107ddc:	85 c0                	test   %eax,%eax
80107dde:	79 07                	jns    80107de7 <setupkvm+0x9d>
      return 0;
80107de0:	b8 00 00 00 00       	mov    $0x0,%eax
80107de5:	eb 10                	jmp    80107df7 <setupkvm+0xad>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107de7:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107deb:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80107df2:	72 b7                	jb     80107dab <setupkvm+0x61>
  return pgdir;
80107df4:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107df7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107dfa:	c9                   	leave
80107dfb:	c3                   	ret

80107dfc <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107dfc:	55                   	push   %ebp
80107dfd:	89 e5                	mov    %esp,%ebp
80107dff:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107e02:	e8 43 ff ff ff       	call   80107d4a <setupkvm>
80107e07:	a3 a0 40 11 80       	mov    %eax,0x801140a0
  switchkvm();
80107e0c:	e8 03 00 00 00       	call   80107e14 <switchkvm>
}
80107e11:	90                   	nop
80107e12:	c9                   	leave
80107e13:	c3                   	ret

80107e14 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107e14:	55                   	push   %ebp
80107e15:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80107e17:	a1 a0 40 11 80       	mov    0x801140a0,%eax
80107e1c:	50                   	push   %eax
80107e1d:	e8 69 f9 ff ff       	call   8010778b <v2p>
80107e22:	83 c4 04             	add    $0x4,%esp
80107e25:	50                   	push   %eax
80107e26:	e8 54 f9 ff ff       	call   8010777f <lcr3>
80107e2b:	83 c4 04             	add    $0x4,%esp
}
80107e2e:	90                   	nop
80107e2f:	c9                   	leave
80107e30:	c3                   	ret

80107e31 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107e31:	55                   	push   %ebp
80107e32:	89 e5                	mov    %esp,%ebp
80107e34:	56                   	push   %esi
80107e35:	53                   	push   %ebx
  pushcli();
80107e36:	e8 68 d3 ff ff       	call   801051a3 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80107e3b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107e41:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107e48:	83 c2 08             	add    $0x8,%edx
80107e4b:	89 d6                	mov    %edx,%esi
80107e4d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107e54:	83 c2 08             	add    $0x8,%edx
80107e57:	c1 ea 10             	shr    $0x10,%edx
80107e5a:	89 d3                	mov    %edx,%ebx
80107e5c:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80107e63:	83 c2 08             	add    $0x8,%edx
80107e66:	c1 ea 18             	shr    $0x18,%edx
80107e69:	89 d1                	mov    %edx,%ecx
80107e6b:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
80107e72:	67 00 
80107e74:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80107e7b:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80107e81:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107e88:	83 e2 f0             	and    $0xfffffff0,%edx
80107e8b:	83 ca 09             	or     $0x9,%edx
80107e8e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107e94:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107e9b:	83 ca 10             	or     $0x10,%edx
80107e9e:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107ea4:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107eab:	83 e2 9f             	and    $0xffffff9f,%edx
80107eae:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107eb4:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107ebb:	83 ca 80             	or     $0xffffff80,%edx
80107ebe:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80107ec4:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107ecb:	83 e2 f0             	and    $0xfffffff0,%edx
80107ece:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107ed4:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107edb:	83 e2 ef             	and    $0xffffffef,%edx
80107ede:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107ee4:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107eeb:	83 e2 df             	and    $0xffffffdf,%edx
80107eee:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107ef4:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107efb:	83 ca 40             	or     $0x40,%edx
80107efe:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107f04:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80107f0b:	83 e2 7f             	and    $0x7f,%edx
80107f0e:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80107f14:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80107f1a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107f20:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80107f27:	83 e2 ef             	and    $0xffffffef,%edx
80107f2a:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80107f30:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107f36:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80107f3c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107f42:	8b 40 08             	mov    0x8(%eax),%eax
80107f45:	89 c2                	mov    %eax,%edx
80107f47:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107f4d:	81 c2 00 10 00 00    	add    $0x1000,%edx
80107f53:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80107f56:	83 ec 0c             	sub    $0xc,%esp
80107f59:	6a 30                	push   $0x30
80107f5b:	e8 f2 f7 ff ff       	call   80107752 <ltr>
80107f60:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
80107f63:	8b 45 08             	mov    0x8(%ebp),%eax
80107f66:	8b 40 04             	mov    0x4(%eax),%eax
80107f69:	85 c0                	test   %eax,%eax
80107f6b:	75 0d                	jne    80107f7a <switchuvm+0x149>
    panic("switchuvm: no pgdir");
80107f6d:	83 ec 0c             	sub    $0xc,%esp
80107f70:	68 6f 8b 10 80       	push   $0x80108b6f
80107f75:	e8 ff 85 ff ff       	call   80100579 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80107f7a:	8b 45 08             	mov    0x8(%ebp),%eax
80107f7d:	8b 40 04             	mov    0x4(%eax),%eax
80107f80:	83 ec 0c             	sub    $0xc,%esp
80107f83:	50                   	push   %eax
80107f84:	e8 02 f8 ff ff       	call   8010778b <v2p>
80107f89:	83 c4 10             	add    $0x10,%esp
80107f8c:	83 ec 0c             	sub    $0xc,%esp
80107f8f:	50                   	push   %eax
80107f90:	e8 ea f7 ff ff       	call   8010777f <lcr3>
80107f95:	83 c4 10             	add    $0x10,%esp
  popcli();
80107f98:	e8 4b d2 ff ff       	call   801051e8 <popcli>
}
80107f9d:	90                   	nop
80107f9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107fa1:	5b                   	pop    %ebx
80107fa2:	5e                   	pop    %esi
80107fa3:	5d                   	pop    %ebp
80107fa4:	c3                   	ret

80107fa5 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80107fa5:	55                   	push   %ebp
80107fa6:	89 e5                	mov    %esp,%ebp
80107fa8:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80107fab:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80107fb2:	76 0d                	jbe    80107fc1 <inituvm+0x1c>
    panic("inituvm: more than a page");
80107fb4:	83 ec 0c             	sub    $0xc,%esp
80107fb7:	68 83 8b 10 80       	push   $0x80108b83
80107fbc:	e8 b8 85 ff ff       	call   80100579 <panic>
  mem = kalloc();
80107fc1:	e8 b3 ac ff ff       	call   80102c79 <kalloc>
80107fc6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80107fc9:	83 ec 04             	sub    $0x4,%esp
80107fcc:	68 00 10 00 00       	push   $0x1000
80107fd1:	6a 00                	push   $0x0
80107fd3:	ff 75 f4             	push   -0xc(%ebp)
80107fd6:	e8 ce d2 ff ff       	call   801052a9 <memset>
80107fdb:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
80107fde:	83 ec 0c             	sub    $0xc,%esp
80107fe1:	ff 75 f4             	push   -0xc(%ebp)
80107fe4:	e8 a2 f7 ff ff       	call   8010778b <v2p>
80107fe9:	83 c4 10             	add    $0x10,%esp
80107fec:	83 ec 0c             	sub    $0xc,%esp
80107fef:	6a 06                	push   $0x6
80107ff1:	50                   	push   %eax
80107ff2:	68 00 10 00 00       	push   $0x1000
80107ff7:	6a 00                	push   $0x0
80107ff9:	ff 75 08             	push   0x8(%ebp)
80107ffc:	e8 b9 fc ff ff       	call   80107cba <mappages>
80108001:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
80108004:	83 ec 04             	sub    $0x4,%esp
80108007:	ff 75 10             	push   0x10(%ebp)
8010800a:	ff 75 0c             	push   0xc(%ebp)
8010800d:	ff 75 f4             	push   -0xc(%ebp)
80108010:	e8 53 d3 ff ff       	call   80105368 <memmove>
80108015:	83 c4 10             	add    $0x10,%esp
}
80108018:	90                   	nop
80108019:	c9                   	leave
8010801a:	c3                   	ret

8010801b <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010801b:	55                   	push   %ebp
8010801c:	89 e5                	mov    %esp,%ebp
8010801e:	53                   	push   %ebx
8010801f:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108022:	8b 45 0c             	mov    0xc(%ebp),%eax
80108025:	25 ff 0f 00 00       	and    $0xfff,%eax
8010802a:	85 c0                	test   %eax,%eax
8010802c:	74 0d                	je     8010803b <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
8010802e:	83 ec 0c             	sub    $0xc,%esp
80108031:	68 a0 8b 10 80       	push   $0x80108ba0
80108036:	e8 3e 85 ff ff       	call   80100579 <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010803b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108042:	e9 95 00 00 00       	jmp    801080dc <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108047:	8b 55 0c             	mov    0xc(%ebp),%edx
8010804a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804d:	01 d0                	add    %edx,%eax
8010804f:	83 ec 04             	sub    $0x4,%esp
80108052:	6a 00                	push   $0x0
80108054:	50                   	push   %eax
80108055:	ff 75 08             	push   0x8(%ebp)
80108058:	e8 bd fb ff ff       	call   80107c1a <walkpgdir>
8010805d:	83 c4 10             	add    $0x10,%esp
80108060:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108063:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108067:	75 0d                	jne    80108076 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108069:	83 ec 0c             	sub    $0xc,%esp
8010806c:	68 c3 8b 10 80       	push   $0x80108bc3
80108071:	e8 03 85 ff ff       	call   80100579 <panic>
    pa = PTE_ADDR(*pte);
80108076:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108079:	8b 00                	mov    (%eax),%eax
8010807b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108080:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108083:	8b 45 18             	mov    0x18(%ebp),%eax
80108086:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108089:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010808e:	77 0b                	ja     8010809b <loaduvm+0x80>
      n = sz - i;
80108090:	8b 45 18             	mov    0x18(%ebp),%eax
80108093:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108096:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108099:	eb 07                	jmp    801080a2 <loaduvm+0x87>
    else
      n = PGSIZE;
8010809b:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
801080a2:	8b 55 14             	mov    0x14(%ebp),%edx
801080a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a8:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801080ab:	83 ec 0c             	sub    $0xc,%esp
801080ae:	ff 75 e8             	push   -0x18(%ebp)
801080b1:	e8 e2 f6 ff ff       	call   80107798 <p2v>
801080b6:	83 c4 10             	add    $0x10,%esp
801080b9:	ff 75 f0             	push   -0x10(%ebp)
801080bc:	53                   	push   %ebx
801080bd:	50                   	push   %eax
801080be:	ff 75 10             	push   0x10(%ebp)
801080c1:	e8 2c 9e ff ff       	call   80101ef2 <readi>
801080c6:	83 c4 10             	add    $0x10,%esp
801080c9:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801080cc:	74 07                	je     801080d5 <loaduvm+0xba>
      return -1;
801080ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801080d3:	eb 18                	jmp    801080ed <loaduvm+0xd2>
  for(i = 0; i < sz; i += PGSIZE){
801080d5:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801080dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080df:	3b 45 18             	cmp    0x18(%ebp),%eax
801080e2:	0f 82 5f ff ff ff    	jb     80108047 <loaduvm+0x2c>
  }
  return 0;
801080e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801080ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801080f0:	c9                   	leave
801080f1:	c3                   	ret

801080f2 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801080f2:	55                   	push   %ebp
801080f3:	89 e5                	mov    %esp,%ebp
801080f5:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801080f8:	8b 45 10             	mov    0x10(%ebp),%eax
801080fb:	85 c0                	test   %eax,%eax
801080fd:	79 0a                	jns    80108109 <allocuvm+0x17>
    return 0;
801080ff:	b8 00 00 00 00       	mov    $0x0,%eax
80108104:	e9 ae 00 00 00       	jmp    801081b7 <allocuvm+0xc5>
  if(newsz < oldsz)
80108109:	8b 45 10             	mov    0x10(%ebp),%eax
8010810c:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010810f:	73 08                	jae    80108119 <allocuvm+0x27>
    return oldsz;
80108111:	8b 45 0c             	mov    0xc(%ebp),%eax
80108114:	e9 9e 00 00 00       	jmp    801081b7 <allocuvm+0xc5>

  a = PGROUNDUP(oldsz);
80108119:	8b 45 0c             	mov    0xc(%ebp),%eax
8010811c:	05 ff 0f 00 00       	add    $0xfff,%eax
80108121:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108126:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108129:	eb 7d                	jmp    801081a8 <allocuvm+0xb6>
    mem = kalloc();
8010812b:	e8 49 ab ff ff       	call   80102c79 <kalloc>
80108130:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108133:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108137:	75 2b                	jne    80108164 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80108139:	83 ec 0c             	sub    $0xc,%esp
8010813c:	68 e1 8b 10 80       	push   $0x80108be1
80108141:	e8 7e 82 ff ff       	call   801003c4 <cprintf>
80108146:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108149:	83 ec 04             	sub    $0x4,%esp
8010814c:	ff 75 0c             	push   0xc(%ebp)
8010814f:	ff 75 10             	push   0x10(%ebp)
80108152:	ff 75 08             	push   0x8(%ebp)
80108155:	e8 5f 00 00 00       	call   801081b9 <deallocuvm>
8010815a:	83 c4 10             	add    $0x10,%esp
      return 0;
8010815d:	b8 00 00 00 00       	mov    $0x0,%eax
80108162:	eb 53                	jmp    801081b7 <allocuvm+0xc5>
    }
    memset(mem, 0, PGSIZE);
80108164:	83 ec 04             	sub    $0x4,%esp
80108167:	68 00 10 00 00       	push   $0x1000
8010816c:	6a 00                	push   $0x0
8010816e:	ff 75 f0             	push   -0x10(%ebp)
80108171:	e8 33 d1 ff ff       	call   801052a9 <memset>
80108176:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108179:	83 ec 0c             	sub    $0xc,%esp
8010817c:	ff 75 f0             	push   -0x10(%ebp)
8010817f:	e8 07 f6 ff ff       	call   8010778b <v2p>
80108184:	83 c4 10             	add    $0x10,%esp
80108187:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010818a:	83 ec 0c             	sub    $0xc,%esp
8010818d:	6a 06                	push   $0x6
8010818f:	50                   	push   %eax
80108190:	68 00 10 00 00       	push   $0x1000
80108195:	52                   	push   %edx
80108196:	ff 75 08             	push   0x8(%ebp)
80108199:	e8 1c fb ff ff       	call   80107cba <mappages>
8010819e:	83 c4 20             	add    $0x20,%esp
  for(; a < newsz; a += PGSIZE){
801081a1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801081a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ab:	3b 45 10             	cmp    0x10(%ebp),%eax
801081ae:	0f 82 77 ff ff ff    	jb     8010812b <allocuvm+0x39>
  }
  return newsz;
801081b4:	8b 45 10             	mov    0x10(%ebp),%eax
}
801081b7:	c9                   	leave
801081b8:	c3                   	ret

801081b9 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801081b9:	55                   	push   %ebp
801081ba:	89 e5                	mov    %esp,%ebp
801081bc:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801081bf:	8b 45 10             	mov    0x10(%ebp),%eax
801081c2:	3b 45 0c             	cmp    0xc(%ebp),%eax
801081c5:	72 08                	jb     801081cf <deallocuvm+0x16>
    return oldsz;
801081c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801081ca:	e9 a5 00 00 00       	jmp    80108274 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
801081cf:	8b 45 10             	mov    0x10(%ebp),%eax
801081d2:	05 ff 0f 00 00       	add    $0xfff,%eax
801081d7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801081dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801081df:	e9 81 00 00 00       	jmp    80108265 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
801081e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081e7:	83 ec 04             	sub    $0x4,%esp
801081ea:	6a 00                	push   $0x0
801081ec:	50                   	push   %eax
801081ed:	ff 75 08             	push   0x8(%ebp)
801081f0:	e8 25 fa ff ff       	call   80107c1a <walkpgdir>
801081f5:	83 c4 10             	add    $0x10,%esp
801081f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801081fb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801081ff:	75 09                	jne    8010820a <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80108201:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108208:	eb 54                	jmp    8010825e <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
8010820a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010820d:	8b 00                	mov    (%eax),%eax
8010820f:	83 e0 01             	and    $0x1,%eax
80108212:	85 c0                	test   %eax,%eax
80108214:	74 48                	je     8010825e <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80108216:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108219:	8b 00                	mov    (%eax),%eax
8010821b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108220:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108223:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108227:	75 0d                	jne    80108236 <deallocuvm+0x7d>
        panic("kfree");
80108229:	83 ec 0c             	sub    $0xc,%esp
8010822c:	68 f9 8b 10 80       	push   $0x80108bf9
80108231:	e8 43 83 ff ff       	call   80100579 <panic>
      char *v = p2v(pa);
80108236:	83 ec 0c             	sub    $0xc,%esp
80108239:	ff 75 ec             	push   -0x14(%ebp)
8010823c:	e8 57 f5 ff ff       	call   80107798 <p2v>
80108241:	83 c4 10             	add    $0x10,%esp
80108244:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108247:	83 ec 0c             	sub    $0xc,%esp
8010824a:	ff 75 e8             	push   -0x18(%ebp)
8010824d:	e8 8a a9 ff ff       	call   80102bdc <kfree>
80108252:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108255:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108258:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
8010825e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108265:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108268:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010826b:	0f 82 73 ff ff ff    	jb     801081e4 <deallocuvm+0x2b>
    }
  }
  return newsz;
80108271:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108274:	c9                   	leave
80108275:	c3                   	ret

80108276 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108276:	55                   	push   %ebp
80108277:	89 e5                	mov    %esp,%ebp
80108279:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
8010827c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108280:	75 0d                	jne    8010828f <freevm+0x19>
    panic("freevm: no pgdir");
80108282:	83 ec 0c             	sub    $0xc,%esp
80108285:	68 ff 8b 10 80       	push   $0x80108bff
8010828a:	e8 ea 82 ff ff       	call   80100579 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010828f:	83 ec 04             	sub    $0x4,%esp
80108292:	6a 00                	push   $0x0
80108294:	68 00 00 00 80       	push   $0x80000000
80108299:	ff 75 08             	push   0x8(%ebp)
8010829c:	e8 18 ff ff ff       	call   801081b9 <deallocuvm>
801082a1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801082a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801082ab:	eb 4f                	jmp    801082fc <freevm+0x86>
    if(pgdir[i] & PTE_P){
801082ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082b0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801082b7:	8b 45 08             	mov    0x8(%ebp),%eax
801082ba:	01 d0                	add    %edx,%eax
801082bc:	8b 00                	mov    (%eax),%eax
801082be:	83 e0 01             	and    $0x1,%eax
801082c1:	85 c0                	test   %eax,%eax
801082c3:	74 33                	je     801082f8 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801082c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082c8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801082cf:	8b 45 08             	mov    0x8(%ebp),%eax
801082d2:	01 d0                	add    %edx,%eax
801082d4:	8b 00                	mov    (%eax),%eax
801082d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082db:	83 ec 0c             	sub    $0xc,%esp
801082de:	50                   	push   %eax
801082df:	e8 b4 f4 ff ff       	call   80107798 <p2v>
801082e4:	83 c4 10             	add    $0x10,%esp
801082e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801082ea:	83 ec 0c             	sub    $0xc,%esp
801082ed:	ff 75 f0             	push   -0x10(%ebp)
801082f0:	e8 e7 a8 ff ff       	call   80102bdc <kfree>
801082f5:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801082f8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801082fc:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108303:	76 a8                	jbe    801082ad <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
80108305:	83 ec 0c             	sub    $0xc,%esp
80108308:	ff 75 08             	push   0x8(%ebp)
8010830b:	e8 cc a8 ff ff       	call   80102bdc <kfree>
80108310:	83 c4 10             	add    $0x10,%esp
}
80108313:	90                   	nop
80108314:	c9                   	leave
80108315:	c3                   	ret

80108316 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108316:	55                   	push   %ebp
80108317:	89 e5                	mov    %esp,%ebp
80108319:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010831c:	83 ec 04             	sub    $0x4,%esp
8010831f:	6a 00                	push   $0x0
80108321:	ff 75 0c             	push   0xc(%ebp)
80108324:	ff 75 08             	push   0x8(%ebp)
80108327:	e8 ee f8 ff ff       	call   80107c1a <walkpgdir>
8010832c:	83 c4 10             	add    $0x10,%esp
8010832f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108332:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108336:	75 0d                	jne    80108345 <clearpteu+0x2f>
    panic("clearpteu");
80108338:	83 ec 0c             	sub    $0xc,%esp
8010833b:	68 10 8c 10 80       	push   $0x80108c10
80108340:	e8 34 82 ff ff       	call   80100579 <panic>
  *pte &= ~PTE_U;
80108345:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108348:	8b 00                	mov    (%eax),%eax
8010834a:	83 e0 fb             	and    $0xfffffffb,%eax
8010834d:	89 c2                	mov    %eax,%edx
8010834f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108352:	89 10                	mov    %edx,(%eax)
}
80108354:	90                   	nop
80108355:	c9                   	leave
80108356:	c3                   	ret

80108357 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108357:	55                   	push   %ebp
80108358:	89 e5                	mov    %esp,%ebp
8010835a:	53                   	push   %ebx
8010835b:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010835e:	e8 e7 f9 ff ff       	call   80107d4a <setupkvm>
80108363:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108366:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010836a:	75 0a                	jne    80108376 <copyuvm+0x1f>
    return 0;
8010836c:	b8 00 00 00 00       	mov    $0x0,%eax
80108371:	e9 f6 00 00 00       	jmp    8010846c <copyuvm+0x115>
  for(i = 0; i < sz; i += PGSIZE){
80108376:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010837d:	e9 c2 00 00 00       	jmp    80108444 <copyuvm+0xed>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108382:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108385:	83 ec 04             	sub    $0x4,%esp
80108388:	6a 00                	push   $0x0
8010838a:	50                   	push   %eax
8010838b:	ff 75 08             	push   0x8(%ebp)
8010838e:	e8 87 f8 ff ff       	call   80107c1a <walkpgdir>
80108393:	83 c4 10             	add    $0x10,%esp
80108396:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108399:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010839d:	75 0d                	jne    801083ac <copyuvm+0x55>
      panic("copyuvm: pte should exist");
8010839f:	83 ec 0c             	sub    $0xc,%esp
801083a2:	68 1a 8c 10 80       	push   $0x80108c1a
801083a7:	e8 cd 81 ff ff       	call   80100579 <panic>
    if(!(*pte & PTE_P))
801083ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083af:	8b 00                	mov    (%eax),%eax
801083b1:	83 e0 01             	and    $0x1,%eax
801083b4:	85 c0                	test   %eax,%eax
801083b6:	75 0d                	jne    801083c5 <copyuvm+0x6e>
      panic("copyuvm: page not present");
801083b8:	83 ec 0c             	sub    $0xc,%esp
801083bb:	68 34 8c 10 80       	push   $0x80108c34
801083c0:	e8 b4 81 ff ff       	call   80100579 <panic>
    pa = PTE_ADDR(*pte);
801083c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083c8:	8b 00                	mov    (%eax),%eax
801083ca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083cf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801083d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801083d5:	8b 00                	mov    (%eax),%eax
801083d7:	25 ff 0f 00 00       	and    $0xfff,%eax
801083dc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801083df:	e8 95 a8 ff ff       	call   80102c79 <kalloc>
801083e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
801083e7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801083eb:	74 68                	je     80108455 <copyuvm+0xfe>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
801083ed:	83 ec 0c             	sub    $0xc,%esp
801083f0:	ff 75 e8             	push   -0x18(%ebp)
801083f3:	e8 a0 f3 ff ff       	call   80107798 <p2v>
801083f8:	83 c4 10             	add    $0x10,%esp
801083fb:	83 ec 04             	sub    $0x4,%esp
801083fe:	68 00 10 00 00       	push   $0x1000
80108403:	50                   	push   %eax
80108404:	ff 75 e0             	push   -0x20(%ebp)
80108407:	e8 5c cf ff ff       	call   80105368 <memmove>
8010840c:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
8010840f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108412:	83 ec 0c             	sub    $0xc,%esp
80108415:	ff 75 e0             	push   -0x20(%ebp)
80108418:	e8 6e f3 ff ff       	call   8010778b <v2p>
8010841d:	83 c4 10             	add    $0x10,%esp
80108420:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108423:	83 ec 0c             	sub    $0xc,%esp
80108426:	53                   	push   %ebx
80108427:	50                   	push   %eax
80108428:	68 00 10 00 00       	push   $0x1000
8010842d:	52                   	push   %edx
8010842e:	ff 75 f0             	push   -0x10(%ebp)
80108431:	e8 84 f8 ff ff       	call   80107cba <mappages>
80108436:	83 c4 20             	add    $0x20,%esp
80108439:	85 c0                	test   %eax,%eax
8010843b:	78 1b                	js     80108458 <copyuvm+0x101>
  for(i = 0; i < sz; i += PGSIZE){
8010843d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108444:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108447:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010844a:	0f 82 32 ff ff ff    	jb     80108382 <copyuvm+0x2b>
      goto bad;
  }
  return d;
80108450:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108453:	eb 17                	jmp    8010846c <copyuvm+0x115>
      goto bad;
80108455:	90                   	nop
80108456:	eb 01                	jmp    80108459 <copyuvm+0x102>
      goto bad;
80108458:	90                   	nop

bad:
  freevm(d);
80108459:	83 ec 0c             	sub    $0xc,%esp
8010845c:	ff 75 f0             	push   -0x10(%ebp)
8010845f:	e8 12 fe ff ff       	call   80108276 <freevm>
80108464:	83 c4 10             	add    $0x10,%esp
  return 0;
80108467:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010846c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010846f:	c9                   	leave
80108470:	c3                   	ret

80108471 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108471:	55                   	push   %ebp
80108472:	89 e5                	mov    %esp,%ebp
80108474:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108477:	83 ec 04             	sub    $0x4,%esp
8010847a:	6a 00                	push   $0x0
8010847c:	ff 75 0c             	push   0xc(%ebp)
8010847f:	ff 75 08             	push   0x8(%ebp)
80108482:	e8 93 f7 ff ff       	call   80107c1a <walkpgdir>
80108487:	83 c4 10             	add    $0x10,%esp
8010848a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010848d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108490:	8b 00                	mov    (%eax),%eax
80108492:	83 e0 01             	and    $0x1,%eax
80108495:	85 c0                	test   %eax,%eax
80108497:	75 07                	jne    801084a0 <uva2ka+0x2f>
    return 0;
80108499:	b8 00 00 00 00       	mov    $0x0,%eax
8010849e:	eb 2a                	jmp    801084ca <uva2ka+0x59>
  if((*pte & PTE_U) == 0)
801084a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a3:	8b 00                	mov    (%eax),%eax
801084a5:	83 e0 04             	and    $0x4,%eax
801084a8:	85 c0                	test   %eax,%eax
801084aa:	75 07                	jne    801084b3 <uva2ka+0x42>
    return 0;
801084ac:	b8 00 00 00 00       	mov    $0x0,%eax
801084b1:	eb 17                	jmp    801084ca <uva2ka+0x59>
  return (char*)p2v(PTE_ADDR(*pte));
801084b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b6:	8b 00                	mov    (%eax),%eax
801084b8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084bd:	83 ec 0c             	sub    $0xc,%esp
801084c0:	50                   	push   %eax
801084c1:	e8 d2 f2 ff ff       	call   80107798 <p2v>
801084c6:	83 c4 10             	add    $0x10,%esp
801084c9:	90                   	nop
}
801084ca:	c9                   	leave
801084cb:	c3                   	ret

801084cc <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801084cc:	55                   	push   %ebp
801084cd:	89 e5                	mov    %esp,%ebp
801084cf:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801084d2:	8b 45 10             	mov    0x10(%ebp),%eax
801084d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801084d8:	eb 7f                	jmp    80108559 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801084da:	8b 45 0c             	mov    0xc(%ebp),%eax
801084dd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801084e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084e8:	83 ec 08             	sub    $0x8,%esp
801084eb:	50                   	push   %eax
801084ec:	ff 75 08             	push   0x8(%ebp)
801084ef:	e8 7d ff ff ff       	call   80108471 <uva2ka>
801084f4:	83 c4 10             	add    $0x10,%esp
801084f7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801084fa:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801084fe:	75 07                	jne    80108507 <copyout+0x3b>
      return -1;
80108500:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108505:	eb 61                	jmp    80108568 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108507:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010850a:	2b 45 0c             	sub    0xc(%ebp),%eax
8010850d:	05 00 10 00 00       	add    $0x1000,%eax
80108512:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108515:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108518:	39 45 14             	cmp    %eax,0x14(%ebp)
8010851b:	73 06                	jae    80108523 <copyout+0x57>
      n = len;
8010851d:	8b 45 14             	mov    0x14(%ebp),%eax
80108520:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108523:	8b 45 0c             	mov    0xc(%ebp),%eax
80108526:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108529:	89 c2                	mov    %eax,%edx
8010852b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010852e:	01 d0                	add    %edx,%eax
80108530:	83 ec 04             	sub    $0x4,%esp
80108533:	ff 75 f0             	push   -0x10(%ebp)
80108536:	ff 75 f4             	push   -0xc(%ebp)
80108539:	50                   	push   %eax
8010853a:	e8 29 ce ff ff       	call   80105368 <memmove>
8010853f:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108542:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108545:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108548:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010854b:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010854e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108551:	05 00 10 00 00       	add    $0x1000,%eax
80108556:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108559:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010855d:	0f 85 77 ff ff ff    	jne    801084da <copyout+0xe>
  }
  return 0;
80108563:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108568:	c9                   	leave
80108569:	c3                   	ret
