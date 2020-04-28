#   Copyright (c) 2019, Xilinx, Inc.
#   All rights reserved.
#
#   Redistribution and use in source and binary forms, with or without
#   modification, are permitted provided that the following conditions are met:
#
#   1.  Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#
#   2.  Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#
#   3.  Neither the name of the copyright holder nor the names of its
#       contributors may be used to endorse or promote products derived from
#       this software without specific prior written permission.
#
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
#   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
#   PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
#   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
#   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#   OR BUSINESS INTERRUPTION). HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#   WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#   OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#   ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import os
import sys
import subprocess
import shutil
from distutils.dir_util import copy_tree

from setuptools import find_packages, setup

# global variables
board = os.environ['BOARD']
repo_board_folder = f'hw/{board}/'


def check_env():
    """Check if we're running on PYNQ and if the board is supported."""
    if not os.path.isdir(repo_board_folder):
        raise ValueError("Board {} is not supported.".format(board))


def copy_board_files(subdir):
    """Copy files from board directory to package""" 
    src_dir = os.path.join(repo_board_folder, subdir) 
    dst_dir = os.path.join('audio_lab_pynq', subdir)
    copy_tree(src_dir, dst_dir)

def make_file_list():
    data_files = []
    for new_file_dir, _, new_files in os.walk("audio_lab_pynq"):
        data_files.extend(
            [os.path.join("..", new_file_dir, f) for f in new_files]
        )
    return data_files

check_env()
make_command = ["make", "-C", repo_board_folder]
if subprocess.call(make_command) != 0:
    sys.exit(-1)
copy_board_files('bitstreams')


setup(
    name="audio_lab_pynq",
    version='1.0',
    install_requires=[
        'pynq>=2.4',
        'plotly>=4.1.0',
        'plotly-express>=0.3.1',
        'pylibi2c @ https://github.com/amaork/libi2c/archive/master.zip#egg=pylibi2c-1.0.0'
    ],
    url='https://github.com/cramsay/Audio-Lab-PYNQ',
    license='DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE',
    author="Craig Ramsay",
    author_email="cramsay01@gmail.com",
    packages=find_packages(),
    package_data={'': make_file_list()},
    description="Wee platform for audio DSP using PYNQ and the fecking ADAU1761 chip")
