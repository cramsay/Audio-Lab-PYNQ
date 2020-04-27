# Setup bclk
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets bclk_IBUF]
create_clock -add -name bclk -period 325 -waveform {0 162.5} [get_ports bclk]

## Ignore inter clock paths in timing analysis
set_false_path -from [get_clocks bclk] -to [get_clocks clk_fpga_0]
set_false_path -from [get_clocks clk_fpga_0] -to [get_clocks bclk]

## Audio

## Masater clock
set_property PACKAGE_PIN U5 [get_ports {mclk}]
set_property IOSTANDARD LVCMOS33 [get_ports {mclk}]

## Chip address bits
set_property PACKAGE_PIN M17 [get_ports {codec_address[0]}]  
set_property IOSTANDARD LVCMOS33 [get_ports {codec_address[0]}]

set_property PACKAGE_PIN M18 [get_ports {codec_address[1]}]  
set_property IOSTANDARD LVCMOS33 [get_ports {codec_address[1]}]

## I2C interface
set_property PACKAGE_PIN U9 [get_ports {IIC_1_scl_io}]
set_property PULLUP true [get_ports {IIC_1_scl_io}]  
set_property IOSTANDARD LVCMOS33 [get_ports {IIC_1_scl_io}]

set_property PACKAGE_PIN T9 [get_ports {IIC_1_sda_io}]
set_property PULLUP true [get_ports {IIC_1_sda_io}]  
set_property IOSTANDARD LVCMOS33 [get_ports {IIC_1_sda_io}]

## Aud DIN
set_property PACKAGE_PIN F17 [get_ports {sdata_i}]  
set_property IOSTANDARD LVCMOS33 [get_ports {sdata_i}]

## AUD DOUT
set_property PACKAGE_PIN G18 [get_ports {sdata_o}]  
set_property IOSTANDARD LVCMOS33 [get_ports {sdata_o}]

## AUD  BCLK
set_property PACKAGE_PIN R18 [get_ports {bclk}]  
set_property IOSTANDARD LVCMOS33 [get_ports {bclk}] 


## AUD LRCLK
set_property PACKAGE_PIN T17 [get_ports {lrclk}]  
set_property IOSTANDARD LVCMOS33 [get_ports {lrclk}] 

###################################################
## 24 mhz clock to audio chip
#set_property PACKAGE_PIN AB2 [get_ports {AC_MCLK}]
#set_property IOSTANDARD LVCMOS33 [get_ports {AC_MCLK}]


## I2S transfers audio samples
## i2s bit clock to ADAU1761
#set_property PACKAGE_PIN Y8 [get_ports {AC_GPIO0}]
#set_property IOSTANDARD LVCMOS33 [get_ports {AC_GPIO0}]

## i2s bit clock from ADAU1761
#set_property PACKAGE_PIN AA7 [get_ports {AC_GPIO1}]
#set_property IOSTANDARD LVCMOS33 [get_ports {AC_GPIO1}]

## i2s bit clock from ADAU1761
#set_property PACKAGE_PIN AA6 [get_ports {AC_GPIO2}]
#set_property IOSTANDARD LVCMOS33 [get_ports {AC_GPIO2}]

## i2s l/r 48 khz toggling signal from ADAU1761 (sample clock)
#set_property PACKAGE_PIN Y6 [get_ports {AC_GPIO3}]
#set_property IOSTANDARD LVCMOS33 [get_ports {AC_GPIO3}]


## I2C Data Interface to ADAU1761 (for configuration)
#set_property PACKAGE_PIN AB4 [get_ports {AC_SCK}]
#set_property IOSTANDARD LVCMOS33 [get_ports {AC_SCK}]

#set_property PACKAGE_PIN AB5 [get_ports {AC_SDA}]
#set_property IOSTANDARD LVCMOS33 [get_ports {AC_SDA}]

#set_property PACKAGE_PIN AB1 [get_ports {AC_ADR0}]
#set_property IOSTANDARD LVCMOS33 [get_ports {AC_ADR0}]

#set_property PACKAGE_PIN Y5 [get_ports {AC_ADR1}]
#set_property IOSTANDARD LVCMOS33 [get_ports {AC_ADR1}]


#AC_MCLK      : out   STD_LOGIC                      -- 24 Mhz for ADAU1761

#AC_ADR0      : out   STD_LOGIC                      -- I2C contol signals to ADAU1761, for configuration
#AC_ADR1      : out   STD_LOGIC
#AC_SCK       : out   STD_LOGIC
#AC_SDA       : inout STD_LOGIC

#AC_GPIO0     : out   STD_LOGIC                      -- I2S MISO
#AC_GPIO1     : in    STD_LOGIC                      -- I2S MOSI
#AC_GPIO2     : in    STD_LOGIC                      -- I2S_bclk
#AC_GPIO3     : in    STD_LOGIC                      -- I2S_LR
