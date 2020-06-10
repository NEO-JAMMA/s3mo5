/*********************************************************************
* 
* S3MO5 model -  emulateur MO5
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
**********************************************************************
* genfs - generation du systeme de fichiers
*
*
* xx xx xx      pointeur sur le pointeur du nom du fichier (3 bytes)
* xx xx xx      pointeur sur le fichier k7                 (3 bytes)
* .. .. ..
* .. .. ..
*
* "abcdef"      pointeur sur les noms de fichiers
* "ghijklmnop"
* ...........
* 
* xx xx xx xx xx xx fichier
* xx xx xx xx xx xx
* .. .. .. .. .. ..
*
*********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>
 
int main(int argc,char **argv)
{
  unsigned char buffer[4*1024*1024];
  unsigned char line[256],line2[256];
  struct stat   fileinfo;
  FILE *fs_file,*k7_file;
  unsigned int i,n,count,name_pos,file_pos;
  int          size;
  
  if(argc!=2)
  {
    printf("error: bad argument number !\n");
    printf("usage: %s <fat.txt>\n",argv[0]);
    exit(-1);
  }
  
  for(i=0;i<512*1024;i++) buffer[i]=0;
  
  
  /* parse fat file */
  fs_file=fopen(argv[1],"rb");
  if(!fs_file)
  {
    printf("error: unable to open the fat file !\n");
    exit(-1);
  }

  /* pass1 - get number of file */
  name_pos=0;
  file_pos=0;
  n=0;
  count=0;
  
  while(1)
  {
    fgets(line,256,fs_file);
    fgets(line,256,fs_file);
    if(feof(fs_file)) break;
    n++;
  }
  printf("%d files found\n",n);
  rewind(fs_file);

  
  
  /* pass2 - initialise fs filename fields */
  n++; /* add null pointer */
  name_pos = 6*n;
  while(1)
  {
    
    fgets(line,256,fs_file);
    fgets(line2,256,fs_file);
    if(feof(fs_file)) break;
    
    /* initialise string pointer field */
    i=0;
    buffer[6*count]   = (name_pos>>16)&0xff;
    buffer[6*count+1] = (name_pos>>8)&0xff;
    buffer[6*count+2] = (name_pos)&0xff;
    
    /* copy string */
    while(1)
    {
      if(line2[i]=='\n') break;
      buffer[name_pos]=line2[i];
      i++;
      name_pos++;
    }
    
    while(line[i++]!='\n');
    line[i-1]=0;
    
    buffer[name_pos++]=0;
    
    if(stat(line,&fileinfo))
    {
      printf("error: cannot get info from %s file\n",line);
      exit(-1);
    }
    printf("%s %d\n",line,fileinfo.st_size);
    
    /* copy file */
    
    count++;
  }
  
  /* pass3 - initialise fs data fields */
  
  rewind(fs_file);
  file_pos=name_pos;
  count=0;
  
  while(1)
  {
    fgets(line,256,fs_file);
    fgets(line2,256,fs_file);
    if(feof(fs_file)) break;
    buffer[6*count+3] = (file_pos>>16)&0xff;
    buffer[6*count+4] = (file_pos>>8)&0xff;
    buffer[6*count+5] = (file_pos)&0xff;

    i=0;
    while(line[i++]!='\n');
    line[i-1]=0;
    
    k7_file=fopen(line,"rb");
    if(!k7_file)
    {
      printf("error: unable to open file %s\n",line);
      exit(-1);
    }
    
    
    stat(line,&fileinfo);    
    
    if((file_pos+fileinfo.st_size)>=4*1024*1024)
    {
      printf("error: 4 MBytes limit exceeded (%d)!\n",file_pos+fileinfo.st_size);
      exit(-1);
    }
    
    size=fread(buffer+file_pos,1,fileinfo.st_size,k7_file);
    if(size<=0)
    {
      printf("error: fail to read '%s' (%d) (%d)!\n",line,size,fileinfo.st_size);
      perror(buffer);
      printf("%s\n",buffer);
      exit(-1);
    }
    file_pos=file_pos+size;
    fclose(k7_file);
  
    count++;
  }
  
  
  fclose(fs_file);


  printf("fs file size = %d\n",file_pos);

  /* generate fs_file */
  
  fs_file=fopen("fs.bin","wb");
  if(!fs_file)
  {
    printf("error: unable to create fs.bin !\n");
    exit(-1);
  }
  fwrite(buffer,1,file_pos,fs_file);

  fclose(fs_file);

}
