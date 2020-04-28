from pynq import Overlay
from enum import Enum
import os
from .AxisSwitch import AxisSwitch
from .AudioCodec import ADAU1761

class XbarSource(Enum):
    line_in = 0
    dma     = 1
class XbarEffect(Enum):
    passthrough = 0
    low_pass_filter = 1
class XbarSink(Enum):
    headphone = 0
    dma = 1
    
class AudioLabOverlay(Overlay):
    
    def __init__(self, bitfile_name=None, **kwargs):
        # Generate default bitfile name
        if bitfile_name is None:
            this_dir = os.path.dirname(__file__)
            bitfile_name = os.path.join(this_dir, 'bitstreams', 'audio_lab.bit')
        super().__init__(bitfile_name, **kwargs)
        self.x_source = self.axis_switch_source
        self.x_sink = self.axis_switch_sink
        self.codec = ADAU1761()
        self.codec.config_pll()
        self.codec.config_codec()
        self.route(XbarSource.line_in, XbarEffect.passthrough, XbarSink.headphone)
        
    def route(self, source, effect, sink):    
        self.x_source.start_cfg()
        self.x_sink.start_cfg()
        
        self.x_source.disable_all()
        self.x_sink.disable_all()
        
        self.x_source.route_pair(effect.value,source.value)
        self.x_sink.route_pair(sink.value,effect.value)
        
        self.x_source.stop_cfg()
        self.x_sink.stop_cfg()