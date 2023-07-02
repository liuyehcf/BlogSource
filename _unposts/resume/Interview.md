
# Self Introduction

Nice to meet you! Thank you for taking the time to interview me. My name is Calvin, and I am from China. I obtained both my bachelor's and master's degrees from BUPT (Beijing University of Posts and Telecommunications), where I specialized in communication engineering. During my postgraduate studies, I began self-learning computer science to further broaden my skills.

Throughout my professional journey, I have had the privilege of working for two distinguished companies. The first company is Alibaba Group. During my time there, I was part of the IoT department, where our team focused on developing a platform for managing and controlling various devices, such as smart home security systems and industrial sensors. Additionally, we aimed to facilitate industrial upgrading for diverse industries.

Following my experience at Alibaba Group, I joined a startup called Starrocks, which is widely recognized for its exceptional OALP (Open Analytics and Log Processing) database product in China. This product stands out for its outstanding performance.

Once again, I'm delighted to meet you, and I am eager to discuss more during this interview.

# Question

## Tunnel Service

### Introduction

The Tunnel Service is specifically designed to meet the demand for accessing private network devices through SSH and HTTP protocols. At our platform, we have seamlessly integrated these capabilities into our platform console, available at aliyun.com.

### Basic architecture

The entire service consists of three main components: the tunnel server, user-side agent, and device-side agent. The tunnel server acts as a central hub, facilitating the communication between the user-side agent and the device-side agent. The device-side agent connects to the server and routes messages between the actual local service such as sshd and the server. On the other hand, the user-side agent connects to the server and handles message routing between the user and the server.

For ease of implementation, we have adopted WebSocket as the underlying protocol on both the user-side and device-side. This choice allows for seamless communication and simplifies the integration process.

In the case of SSH proxy, the user-side agent is the SSH component embedded in our console, providing the necessary functionality. On the other hand, for HTTP proxy, any standard web browser can act as the agent, which is truly magical in terms of versatility and convenience.

### Details of the ssh proxy

### Details of the http proxy

## Flow Execution Framework

## Edge Gateway Device

## Database

## Java

## Cpp

## Network

# References

* [cpp-interview](https://github.com/huihut/interview)
* [interview](https://github.com/Olshansk/interview)
* [Interview](https://github.com/apachecn/Interview)