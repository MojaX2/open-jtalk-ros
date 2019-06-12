#!/usr/bin/python
# coding: utf-8

from datetime import datetime
from dynamic_reconfigure.server import Server
import rospy
import os
import jtalk.srv
from std_msgs.msg import String
import subprocess
from jtalk.cfg import JtalkConfig

class OpenJTalk():
    def __init__(self):
        rospy.on_shutdown(self.shutdown)
        rospy.Service("jtalk/say", jtalk.srv.Say, self.say_srv)
        rospy.Subscriber("jtalk/say", String, self.say_callback)
        srv = Server(JtalkConfig, self.params_callback)

        self.params = None

    def params_callback(self, config, level):
        self.params = config
        return config

    def say_srv(self,req):
        if isinstance(req, jtalk.srv.SayRequest):
            rospy.loginfo("uttur: {req.sentence}".format(**locals()))
            try:
                self.opne_jtalk(req.sentence)
            except (Exception) as e:
                rospy.logerr(e)
                return jtalk.srv.SayResponse(False)
            else:
                return jtalk.srv.SayResponse(True)

    def say_callback(self,data):
        rospy.loginfo("uttur: {data.data}".format(**locals()))
        try:
            self.opne_jtalk(data.data)
        except (Exception) as e:
            rospy.logerr(e)
            return jtalk.srv.SayResponse(False)
        else:
            return jtalk.srv.SayResponse(True)

    def opne_jtalk(self,text):
        open_jtalk = ['open_jtalk']
        mech = ['-x','/var/lib/mecab/dic/open-jtalk/naist-jdic']
        htsvoice = ['-m','/usr/share/hts-voice/mei/mei_normal.htsvoice']
        p1 = ['-a',str(self.params['all_pass_constant'])]
        p2 = ['-b',str(self.params['postfiltering_coefficient'])]
        p3 = ['-r',str(self.params['speech_speed_rate'])]
        p4 = ['-fm',str(self.params['additional_half_tone'])]
        p5 = ['-u',str(self.params['voiced_unvoiced_threshold'])]
        p6 = ['-jm',str(self.params['weight_of_GV_for_spectrum'])]
        p7 = ['-jf',str(self.params['weight_of_GV_for_log_F0'])]
        outwav = ['-ow','/tmp/hoge.wav']

        cmd = open_jtalk + mech + htsvoice + p1 + p2 + p3 + p4 + p5 + p6 + p7 + outwav
        c = subprocess.Popen(cmd,stdin=subprocess.PIPE)
        c.stdin.write(text)
        c.stdin.close()
        c.wait()
        aplay = ['aplay','-q','/tmp/hoge.wav']
        wr = subprocess.Popen(aplay)

    def shutdown(self):
        pass

if __name__ == '__main__':
    rospy.init_node('jtalk')
    OpenJTalk()
    rospy.loginfo("start jtalk")
    rospy.spin()
