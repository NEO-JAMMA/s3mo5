/*********************************************************************
* 
* S3MO5 MODEL -  emulateur MO5
* Copyright (C) 2005 Olivier Ringot <oringot@gmail.com>
* 
* This file is part of the S3MO5 project
*
* The S3MO5 project is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public License
* as published by the Free Software Foundation; either version 2
* of the License, or (at your option) any later version.
* 
* The S3MO5 project is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
* 
* You should have received a copy of the GNU General Public License
* along with this S3MO5 project; if not, write to the Free Software
* Foundation, Inc., 51 Franklin Street, Fifth Floor, 
* Boston, MA  02110-1301, USA.
* 
**********************************************************************
* 
* $Revision: $
* $Date: $
* $Source: $
* $Log: $
*
*********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <getopt.h>                                                            
#include <sys/time.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/keysym.h>
#include <X11/keysymdef.h>

#include "s3mo5.h"
#include "mtpack.h"
#include "s19.h"

/*********************************************************************
* 6809 registers and memory global declaration
*********************************************************************/

unsigned char memory[1024*1024];

unsigned char pia0_pra;
unsigned char pia0_ddra;
unsigned char pia0_cra;
unsigned char pia0_prb;
unsigned char pia0_ddrb;
unsigned char pia0_crb;
unsigned char cnt_ext64k;
unsigned char pia1_pra;
unsigned char pia1_ddra;
unsigned char pia1_cra;
unsigned char pia1_prb;
unsigned char pia1_ddrb;
unsigned char pia1_crb;
unsigned char pia2_pra;
unsigned char pia2_ddra;
unsigned char pia2_cra;
unsigned char pia2_prb;
unsigned char pia2_ddrb;
unsigned char pia2_crb;
unsigned char gate_array[4];

unsigned char bios_slide_index_h;
unsigned char bios_slide_index_l;
unsigned char bios_control;
unsigned char bios_control2;

unsigned char sound_buffer[16*1024*1024];
unsigned int  sound_counter;

unsigned char keyboard_mo5[64];
unsigned int  color_bgr_mo5[16]=
{                            
  0x000000, /*  0 noir          */
  0xff0000, /*  1 rouge         */
  0x00ff00, /*  2 vert          */
  0xffff00, /*  3 jaune         */
  0x0000ff, /*  4 bleu          */
  0xff00ff, /*  5 magenta       */
  0x00ffff, /*  6 cyan          */
  0xffffff, /*  7 blanc         */
  0xb0b0b0, /*  8 gris          */
  0xffb0b0, /*  9 rose          */
  0xb0ffb0, /* 10 vert clair    */
  0xffffb0, /* 11 jaune poussin */ 
  0xb0b0ff, /* 12 bleu clair    */
  0xffb0ff, /* 13 rose parme    */
  0xb0ffff, /* 14 cyan clair    */
  0xffb000  /* 15 orange        */
};
 
unsigned int  reset,nmi,irq,fiq,nmi_1t,irq_1t,fiq_1t;
unsigned int  a,b,x,y,u,s,dp,cc,pc;
unsigned int  pa,pb,px,py,pu,ps,pdp,pcc,ppc;
unsigned int  wait_for_interrupt;
unsigned int  cpu_timestep,realtime_timestep;
unsigned int  noirq,nocolor,verbose,rom_ok,bios_ok,realtime;
unsigned int  record_event,event_generation,display_regs_diff,display_memtraffic;
unsigned int  fs_loaded;


char          frame[4*336*216];
char          bios_frame[4*336*216];
Display       *display;
Window        window;
XImage        *image,*bios_image;
XEvent        event;
GC            gc;
KeySym        keysymbol;

FILE         *rom_file,*fs_file,*file_out;
FILE         *event_file,*bios_file,*record_file;

/*********************************************************************
* main
*********************************************************************/

int main(int argc,char**argv)
{
  unsigned char buffer[128];
  unsigned int count,base,opc,mode,op1,tmp,instr_count,delta_instr_count;
  unsigned int (*exec)(unsigned int,unsigned int);
  unsigned int i,j,k,option_index;
  unsigned int c,next_event,next_key,next_val;
  
  struct option long_option[]=
  {
    { "help",           0,   0,   0},
    { "s19",            1,   0,   0},
    { "verbose",        0,   0,   0},
    { "nocolor",        0,   0,   0},
    { "realtime",       1,   0,   0},
    { "novsync",        0,   0,   0},
    { "event",          1,   0,   0},
    { "record",         1,   0,   0},
    { "diffreg",        0,   0,   0},
    { "memtraffic",     1,   0,   0},
    { 0,                0,   0,   0}
  };
  
  struct itimerval vsync_timeval;
  
  /* set flags */
  if(argc==1)
  {
    printf("error: bad argument number !\n");
    printf("type %s --help for more information\n",argv[0]);
    exit(-1);
  }

  nocolor            = 0;
  verbose            = 0;
  realtime           = 0;
  rom_ok             = 0;
  bios_ok            = 0;
  noirq              = 0;
  event_generation   = 0;
  record_event       = 0;
  fs_loaded          = 0;
  display_regs_diff  = 0;
  display_memtraffic = 0;
   
  while(1)
  {
    c=getopt_long(argc,argv,"",long_option,&option_index);
   
    if(c==-1) break;
    
    switch(c)
    {
      case 0:
      
        switch(option_index)
        {
          
          case 0:
          
            printf("\nS3MO5 V1.0    - MO5 Computer Behavioural Model\n");
            printf("April 7, 2005 - (C) Olivier Ringot\n");
            printf("\nOptions:\n\n");
            printf("  --help               : Display this help\n");
            printf("  --s19=<file.s19>     : S19 image file\n");
            printf("  --realtime=<integer> : Executed cycles per 20 ms (real=20000, default=max)\n");
            printf("  --event=<file>       : Generate events from an event file\n");
            printf("  --record=<file>      : Record keyboard events to an event file\n");
            printf("  --novsync            : Ignore vsync interruption\n");
            printf("  --verbose            : Disassemble and display registers during execution\n");
            printf("  --memtraffic=<file>  : Record cpu memory traffic\n");
            printf("  --diffreg            : display only registers changes\n");
            printf("  --nocolor            : Do not display any color during tracing\n");
            printf("\n\n");
            exit(-1);
            break;
          
          case 1:
          
            /* read s19 memory file */
            rom_file=fopen(optarg,"rb");
            if(!rom_file)
            {
              printf("error: unable to open '%s' s19 file !\n",optarg);
              exit(-1);
            }
  
            s19_read(rom_file,memory,1024*1024);
            
            fclose(rom_file);
            rom_ok=1;
            break;
          
          case 2:
          
            verbose=1;
            break;
            
          case 3:
          
            nocolor=1;
            break;
            
          case 4:
          
            realtime=atoi(optarg);
            break;

          case 5:
          
            noirq=1;
            break;
            
          case 6:
          
            event_generation=1;
            
            event_file = fopen(optarg,"rb");
            if(!event_file)
            {
              printf("error: unable to open event file !\n");
              exit(-1);
            }
            
            break; 
           
          case 7:
            
            record_file = fopen(optarg,"wb");
            
            if(!record_file)
            {
              printf("error: unable to create record file !\n");
              exit(-1);
            }
            record_event=1;
            break;
          
          case 8:
            
            display_regs_diff=1;
            break;

          case 9:
          
            display_memtraffic=1;
            mtpack_file = gzopen(optarg,"wb9");
  
            if(!mtpack_file)
            {
              printf("error: unable to open %s file !\n",optarg);
              exit(-1);
            }
            break;
          
          default:
          
            printf("error: unknown option !\n");
            exit(-1);
        }
        break;
      
      case ':':
     
        printf("argument missing !\n");
        exit(-1);
    
      case '?':
      
        printf("argument unknown !\n");
        exit(-1);
      
      default:
      
        exit(-1);
    }
  }
  
  if(!rom_ok)
  {
    printf("error: you must specify a rom file ! see --help for more info.\n");
    exit(-1);
  }
  
  if(event_generation && record_event)
  {
    printf("error: Cannot record and generate events at the same time !\n");
    exit(-1);
  }
  
  /* init X11 display */
  
  display    = XOpenDisplay((char*)NULL);
  window     = XCreateSimpleWindow(display,
                 DefaultRootWindow(display),
                 10,10,336,216,3,
                 BlackPixel(display,DefaultScreen(display)),
                 WhitePixel(display,DefaultScreen(display)));

               XSelectInput(display,window,ExposureMask|KeyPressMask|KeyReleaseMask);
                
               XStoreName(display,window,"S3MO5 - MO5 model");
  gc         = XCreateGC(display,window,0,0);
  
               XMapWindow(display,window); 
  
  image      = XCreateImage(display,DefaultVisual(display,DefaultScreen(display)),
                 24,ZPixmap,0,frame,336,216,8,0);
  
  bios_image = XCreateImage(display,DefaultVisual(display,DefaultScreen(display)),
                 24,ZPixmap,0,bios_frame,336,216,8,0);
  
               XFlush(display);
  
  
  /* init vsync timer */ 
  
  if(!noirq && !event_generation)
  {
    signal(SIGALRM,vsync_interrupt);
    vsync_timeval.it_interval.tv_sec   = 0;
    vsync_timeval.it_interval.tv_usec  = 20000;
    vsync_timeval.it_value.tv_sec      = 0;
    vsync_timeval.it_value.tv_usec     = 20000;
    setitimer(ITIMER_REAL,&vsync_timeval,(struct itimerval*)NULL);
  }
   
  /* init processor*/
  
  cpu_timestep = 0;
  wait_for_interrupt=0;
  pcc=0x50;
  ppc=pa=pb=px=py=ps=pdp=0;
  
  instr_count=0;
  delta_instr_count=0;
  next_event=0;
  
  /* init MO5 system */
  
  sound_counter = 0;
  for(i=0;i<16*1024*1024;i++) sound_buffer[i]=0x00;
  for(i=0;i<0x17fff;i++) memory[i]= 0x00;
  for(i=0;i< 4;i++) gate_array[i]=0xff;

  pia0_ddra          = 0;
  pia0_pra           = 0x80;
  pia0_cra           = 0;
  pia0_ddrb          = 0;
  pia0_prb           = 0x80;
  pia0_crb           = 0;
  pia1_cra           = 0;
  pia1_pra           = 0xff;
  pia1_crb           = 0xc0;
  pia2_cra           = 0;
  pia2_crb           = 0;
  for(i=0;i<64;i++) keyboard_mo5[i]=0;
 
  bios_slide_index_h = 0;
  bios_slide_index_l = 0;
  bios_control       = 0;
  bios_control2      = 0;
  
  /* execution loop */
  
  reset=1;
  nmi = 0;
  fiq = 0;
  irq = 0;

  while(1)
  {
    
    if(event_generation || record_event)                                                                                         
    {                                                                                                            
      if(delta_instr_count==20000)                                                                               
      {                                                                                                          
        vsync_interrupt(0);                                                                                      
        delta_instr_count=0;                                                                                     
      }                                                                                                          
    }                                                                                                            
    
    if(bios_control2&0x80)
    {
      dump_video_bank();
      dump_sound();
      XDestroyWindow(display,window);
      XFlush(display);
      XCloseDisplay(display);
      
      if(display_memtraffic)
      {
        mtpack_flush_buffer();
        gzclose(mtpack_file);
      }
      
      if(record_event)
      {
        fclose(record_file);
      }
      exit(0);
    }
    
    /* map interruptions */
    
    if(bios_control&0x80)
    {
      reset=1;
      bios_control&=0x7f;
    }
    
    if((pia0_crb&0x81)==0x81)  
      irq = 1;                 
    else                       
      irq = 0;
      
    if(bios_control&0x02)
      nmi = 1;
    else
      nmi = 0;                
    
    if(display_memtraffic)
    {
      if(nmi && !nmi_1t)
      {
        /*printf("i nmi 1\n");*/
        /* 0 1111111 10 1 */
        mtpack_nmi(1);
        nmi_1t=1;
      }
      else if(!nmi && nmi_1t)
      {
        /*printf("i nmi 0\n");*/
        /* 0 1111111 10 0 */
        mtpack_nmi(0);
        nmi_1t=0;
      }
     
      if(irq && !irq_1t)
      {
        /*printf("i irq 1\n");*/
        /* 0 1111111 01 1 */
        mtpack_irq(1);
        irq_1t=1;
      }
      else if(!irq && irq_1t)
      {
        /*printf("i irq 0\n");*/
        /* 0 1111111 01 0 */
        mtpack_irq(0);
        irq_1t=0;
      }

      if(fiq && !fiq_1t)
      {
        /*printf("i fiq 1\n");*/
        /* 0 1111111 00 1 */
        mtpack_fiq(1);
        fiq_1t=1;
      }
      else if(!fiq && fiq_1t)
      {
        /*printf("i fiq 0\n");*/
        /* 0 1111111 00 0 */
        mtpack_fiq(0);
        fiq_1t=0;
      }
    }
   
    scan_interrupt(reset,nmi,irq,fiq);
    
    if(verbose)
    {
      printf("** instruction count=%d   cycle elapsed=%d\n",instr_count,cpu_timestep);
      display_registers();
      /*printf("PC=%-.4X A=%-.2X B=%-.2X X=%-.4X Y=%-.4X U=%-.4X S=%-.4X DP=%-.2X CC=%-.2X I=%d\n",
             pc,a,b,x,y,u,s,dp,cc,instr_count);*/
    }
    
    if(display_regs_diff)  display_registers_change();
    
    if(display_memtraffic) mtpack_put_register_changes();
    
    
    if(verbose || display_regs_diff || display_memtraffic)
    {
      pa  = a;
      pb  = b;
      px  = x;
      py  = y;
      pu  = u;
      ps  = s;
      pdp = dp;
      ppc = pc;
      pcc = cc;
    }
    if(verbose) disassemble(pc);
    
    /* 6809 instruction execution */
    
    if(realtime)
    {
      if((cpu_timestep-realtime_timestep)<realtime)
      {
        if(display_memtraffic) mtpack_new_instr(get_instr_cycles(pc));
        execute();
        instr_count++;
      }
    }
    else
    {
      if(display_memtraffic) mtpack_new_instr(get_instr_cycles(pc));
      execute();
      instr_count++;
      delta_instr_count++;
    }
    
    
    reset=0;

    /* scan keyboard */
    
    if(event_generation)
    {
      if(!next_event)
      {
        if(!feof(event_file))
        {
          fgets(buffer,64,event_file);
          sscanf(buffer,"%d %d %d",&next_event,&next_key,&next_val);
        }
      }
      else
      {
        if(instr_count>=next_event)
        {
          if(verbose)  printf("%d %d %d\n",next_event,next_key,next_val);
          fflush(stdout);
          keyboard_mo5[next_key]=next_val;
          next_event=0;
          if(next_key==0xff)
          {
            bios_control |= 0x02;
          }
          
        }
      }
    }
    else
    {
      if(XCheckWindowEvent(display,window,0xffffffff,&event)==True)
      {
        switch(event.type)
        {
          case KeyPress:
          case KeyRelease:
          
            i = (event.type==KeyPress)?1:0;
            
            if(event.xkey.keycode==0x09)
            {
              bios_control |= 0x02;
            }
            
            switch(XLookupKeysym(&(event.xkey),0))
            {
              case XK_Shift_R     :
              case XK_Shift_L     : j=7 ;  break;
              case XK_Alt_R       :   
              case XK_Alt_L       : j=15;  break;
              case XK_a           : j=45;  break;
              case XK_b           : j=20;  break;
              case XK_c           : j=22;  break;
              case XK_d           : j=27;  break;
              case XK_e           : j=43;  break;
              case XK_f           : j=26;  break;
              case XK_g           : j=25;  break;
              case XK_h           : j=24;  break;
              case XK_i           : j=33;  break;
              case XK_j           : j=16;  break;
              case XK_k           : j=17;  break;
              case XK_l           : j=18;  break;
              case XK_m           : j=19;  break;
              case XK_n           : j=0 ;  break;
              case XK_o           : j=34;  break;
              case XK_p           : j=35;  break;
              case XK_q           : j=29;  break;
              case XK_r           : j=42;  break;
              case XK_s           : j=28;  break;
              case XK_t           : j=41;  break;
              case XK_u           : j=32;  break;
              case XK_v           : j=21;  break;
              case XK_w           : j=6 ;  break;
              case XK_x           : j=5 ;  break;
              case XK_y           : j=40;  break;
              case XK_z           : j=44;  break;
              case XK_space       : j=4 ;  break;
              case XK_Up          : j=14;  break;
              case XK_Down        : j=12;  break;
              case XK_Right       : j=11;  break;
              case XK_Left        : j=13;  break;
              case XK_Return      : j=38;  break;
              case XK_KP_Insert   :   
              case XK_KP_0        :         
              case XK_0           : j=51;  break;
              case XK_KP_End      :   
              case XK_1           :         
              case XK_KP_1        : j=61;  break;
              case XK_KP_Down     :   
              case XK_2           :
              case XK_KP_2        : j=60;  break;
              case XK_KP_Page_Down:   
              case XK_3           :         
              case XK_KP_3        : j=59;  break;
              case XK_KP_Left     :   
              case XK_4           :
              case XK_KP_4        : j=58;  break;
              case XK_KP_Begin    :   
              case XK_5           :         
              case XK_KP_5        : j=57;  break;
              case XK_KP_Right    :         
              case XK_6           :   
              case XK_KP_6        : j=56;  break;
              case XK_KP_Home     :         
              case XK_7           :   
              case XK_KP_7        : j=48;  break;
              case XK_KP_Up       :         
              case XK_8           :   
              case XK_KP_8        : j=49;  break;
              case XK_KP_Page_Up  :   
              case XK_9           :         
              case XK_KP_9        : j=50;  break;
              case XK_comma       : j=1 ;  break;
              case XK_KP_Delete   : j=2 ;  break;
              case XK_agrave      : j=3 ;  break;
              case XK_Delete      : j=8 ;  break;
              case XK_Insert      : j=9 ;  break;
              case XK_Home        : j=30;  break;
              case XK_Control_L   : j=46;  break;
              case XK_KP_Add      : j=53;  break;
              case XK_KP_Multiply : j=37;  break;
              case XK_colon       : j=36;  break;
              case XK_twosuperior : j=62;  break;
              case XK_BackSpace   : j=10;  break;
              case XK_KP_Subtract : j=52;  break;         
              case XK_Escape      : j=0xff;break;
              case XK_semicolon   : j=2   ; break;
              default             : j=0;   break;
            }
            //printf("%-.2x\n",XLookupKeysym(&(event.xkey),0));
            keyboard_mo5[j]=i;
            if(record_event)
            {
              fprintf(record_file,"%d %d %d\n",instr_count,j,i);
            }
            
            break; 
          
          case Expose:
          
            break;
          
          default:
            break;
        }
      }
    }
  }
}

void vsync_interrupt(int v)
{
  pia0_crb |= 0x80;
  
  /* refresh video */
  if(bios_control&0x04)
  {
    XPutImage(display,window,gc,bios_image,0,0,0,0,336,216); 
  }
  else
  {
    XPutImage(display,window,gc,image,0,0,0,0,336,216); 
  }
  XFlush(display);
  realtime_timestep=cpu_timestep;
}

void dump_video_bank()
{
  FILE         *file_out;
  unsigned int i,j,k,col_cad,col_back,col_fore,tmp;
  
  file_out=fopen("dump.ppm","wb");
  if(!file_out)
  {
    printf("error: unable to create file !\n");
    exit(-1);
  }
  
  fprintf(file_out,"P6\n336 216\n255\n");
  
  col_cad  = color_bgr_mo5[(pia0_pra>>1)&0x0f];
  for(i=0;i<216;i++)
  {
    for(j=0;j<42;j++)
    {
      tmp=memory[1+2*(40*(i-8)+(j-1))];
      for(k=0;k<8;k++)
      {
        col_fore = color_bgr_mo5[(tmp>>4)&0x0f];
        col_back = color_bgr_mo5[tmp&0x0f];
       
        if((i<8) || (i>=208) || (j<1) || (j>=41))
        {
          fputc((col_cad>>16)&0xff,file_out); /* SR */
          fputc((col_cad>> 8)&0xff,file_out); /* SG */
          fputc((col_cad>> 0)&0xff,file_out); /* SB */
        }
        else
        {
          if(BTST(memory[2*(40*(i-8)+(j-1))],(7-k)))
          {
            fputc((col_fore>>16)&0xff,file_out); /* FR */
            fputc((col_fore>> 8)&0xff,file_out); /* FG */
            fputc((col_fore>> 0)&0xff,file_out); /* FB */
          }
          else
          {
            fputc((col_back>>16)&0xff,file_out); /* BR */
            fputc((col_back>> 8)&0xff,file_out); /* BG */
            fputc((col_back>> 0)&0xff,file_out); /* BB */
          }
        }
      }
    }
  }
  fclose(file_out);

  file_out=fopen("dump.bin","wb");
  if(!file_out)
  {
    printf("error: unable to create file !\n");
    exit(-1);
  }
  for(i=0;i<200;i++)
  {
    for(j=0;j<40;j++)
    {
     fputc(memory[1+2*(j+i*40)]&0xff,file_out);
     fputc(memory[2*(j+i*40)]&0xff,file_out);
    }
  }
  fclose(file_out);
}

void dump_sound()
{
  unsigned int i,v;
  
  v=0;
  for(i=0;i<16*1024*1024;i++)
  {
    if(sound_buffer[i]==1)
    {
      if(v==0)
      {
        v=0x40;
      }
      else
      {
        v=0x00;
      }
    }
    sound_buffer[i]=v;
  }
  
  file_out=fopen("sounddump.bin","wb");                             
  if(!file_out)                                                     
  {                                                                 
    printf("error: unable to create file for sound dump !\n");      
    exit(-1);                                                       
  }                                                                 
  if(fwrite(sound_buffer,1,16*1024*1024,file_out)!=16*1024*1024)    
  {                                                                 
    printf("error: bad byte number written !\n");                   
    exit(-1);                                                       
  }  
  fclose(file_out);                                                               
}

void sound_put_bit()
{
  FILE *file_out;
  static unsigned int first_event=0;
  
  if(sound_counter!=0xffffffff)
  {
    if(!first_event) 
    {
      first_event = cpu_timestep;
    }
    else
    {
      sound_counter=(cpu_timestep-first_event)/100.0;
      if(sound_counter<16*1024*1024)
      {
        sound_buffer[sound_counter]=1;
      }
      else
      {
        sound_counter=0xffffffff;
      }
    }
  }
}
