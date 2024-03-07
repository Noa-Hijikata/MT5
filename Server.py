import socket
import numpy as np
from matplotlib import pyplot as plt
from matplotlib import animation as ani


class SocketServer:
    def __init__(self, adress = '', port = 8080, timeout = 1000, buffer = 1024):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.adress = adress
        self.port = port
        self.timeout = timeout
        self.buffer = buffer
        self.sock.bind((self.adress, self.port))
        self.sock.settimeout(timeout)
        self.MaxDataNum = 1000
        self.xdata = []
        self.ydata = []
        plt.show()

    def __del__(self):
        self.close()

    def close(self):
        try:
            self.sock.shutdown(socket.SHUT_RDWR)
            self.sock.close()
        except:
            pass

    def recvmsg(self):
        self.sock.listen(1)
        print('Server Started')
        self.conn, self.addr = self.sock.accept()
        print('connected to', self.addr)

        while True:
            try:
                data = self.conn.recv(self.buffer)
                msg = data.decode("utf-8")
                if not data:
                    break
                print("received ->", msg)
                self.drawGraph(msg)
                self.conn.send("Server Accepted".encode('utf-8'))
                #self.conn.send(bytes(calcregr(self.cummdata), "utf-8))"))
                #return self.cummdata
            except ConnectionResetError:
                break
            except BrokenPipeError:
                break
        
        self.close()

    def drawGraph(self, msg = ''):

        x, y = map(float, msg.split(','))
        print(x, y)
        if len(self.xdata) > self.MaxDataNum:
            self.xdata.pop(0)
            self.ydata.pop(0)
        self.xdata.append(x)
        self.ydata.append(y)

        plt.ylim(0, 100)
        plt.hlines(y=[20, 80], xmin=0, xmax=len(self.xdata))
        plt.yticks([0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100])
        plt.plot(self.xdata, color="green")
        plt.plot(self.ydata, color="red", linestyle="dashdot")

        plt.pause(0.001)
        

serv = SocketServer('127.0.0.1', 8080)

while True:
    msg = serv.recvmsg()