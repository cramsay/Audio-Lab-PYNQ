from pynq import DefaultIP

# Things to fix up about this driver:
#  * Add safety checks [a la C driver](https://github.com/Xilinx/embeddedsw/blob/master/XilinxProcessorIPLib/drivers/axis_switch/src/xaxis_switch_hw.h)
#  * Think about better interface / language to control the routing

class AxisSwitch(DefaultIP):
    
    CTRL_OFFSET = 0x00
    CFG_OFFSET  = 0x40
    CFG_GATE_MASK = 0x02
    CFG_DISABLE_MASK = 0x80000000
    
    def __init__(self, description):
        super().__init__(description=description)
        self.num_mi = int(description['parameters']['NUM_MI'])
        self.num_si = int(description['parameters']['NUM_SI'])
        self.disable_all()
        
    bindto = ['xilinx.com:ip:axis_switch:1.1']

    def start_cfg(self):
        self.write(AxisSwitch.CTRL_OFFSET,
          self.read(AxisSwitch.CTRL_OFFSET) &
          (~AxisSwitch.CFG_GATE_MASK)
        )
    
    def stop_cfg(self):
        self.write(AxisSwitch.CTRL_OFFSET,
          self.read(AxisSwitch.CTRL_OFFSET) |
          AxisSwitch.CFG_GATE_MASK
        )
    
    def route_pair(self, master, slave):
        self.write(AxisSwitch.CFG_OFFSET+4*master, slave)
    
    def disable_all(self):
        for i in range(self.num_mi):
            self.disable_master(i)
    
    def disable_master(self, master):
        self.write(AxisSwitch.CFG_OFFSET+4*master, AxisSwitch.CFG_DISABLE_MASK)
        

