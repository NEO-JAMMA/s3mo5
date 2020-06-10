In order to compile and simulate the S3MO5 RTL, you need to :

1) compile all the files from the WebISE ${XILINX_PATH}/vhdl/src/unisims directory

  unisim_VPKG.vhd
  unisim_VCOMP.vhd
  unisim_SMODEL.vhd
  unisim_VITAL.vhd
  
  into a library called 'unisim_lib'
  
2) compile all the files from the WebISE ${XILINX_PATH}/vhdl/src/simprims directory

  simprim_Vpackage_mti.vhd
  simprim_Vcomponents_mti.vhd
  simprim_VITAL_mti.vhd  
  simprim_SMODEL_mti.vhd
  
  into a library called 'simprim_lib'

3) compile all the files from the ../hdl direcotry

  cpu_package.vhd                 
  memcntl_package.vhd             
  videocntl_package.vhd           
  keyboard_package.vhd            
  s3mo5_package.vhd               
  testbench_s3mo5_package.vhd     
  videocntl.vhd                   
  memcntl.vhd                     
  keyboard.vhd                    
  uart.vhd                        
  s3mo5.vhd                       
  ram256kx16.vhd                  
  alu.vhd                         
  datapath.vhd                    
  sequencer.vhd                   
  cpu6809.vhd                     
  testbench_s3mo5.vhd             
  s3mo5_rtl_conf.vhd              

  into a library called 's3mo5_lib'
  

4) Create a stimuli set with the help of the C behavioural model

  in ../../model directory, type 'make update_ram'
  
5) launch the simulator by calling the rtl configuration 's3mo5_lib.s3mo5_rtl_conf'
