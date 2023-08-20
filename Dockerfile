# Use the official NVIDIA CUDA image as the base image
FROM nvidia/cuda:11.5.2-devel-ubuntu20.04

# Set environment variables
ENV TZ=Asia/Seoul \
    DEBIAN_FRONTEND=noninteractive
ENV CUDA_HOME=/usr/local/cuda-11.5
ENV LD_LIBRARY_PATH=${CUDA_HOME}/lib64:$LD_LIBRARY_PATH
ENV PATH=${CUDA_HOME}/bin:${PATH}

RUN apt-get update && \
    apt-get install -y tzdata && \
    ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata
    
# Update and install dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y linux-headers-$(uname -r) \
                       cmake \
                       gcc \
                       g++ \
                       python3 \
                       python3-dev \
                       python3-numpy \
                       libavcodec-dev \
                       libavformat-dev \
                       libswscale-dev \
                       libgstreamer-plugins-base1.0-dev \
                       libgstreamer1.0-dev \
                       libgtk-3-dev \
                       libpng-dev \
                       libjpeg-dev \
                       libopenexr-dev \
                       libtiff-dev \
                       libwebp-dev \
                       git

# Clone OpenCV repository and OpenCV's extra modules repository
RUN git clone https://github.com/opencv/opencv.git && \
    git clone https://github.com/opencv/opencv_contrib.git

# Install cuDNN (assuming you have already downloaded the cuDNN .deb file)
COPY cudnn-local-repo-ubuntu2004-8.3.2.44_1.0-1_amd64.deb /tmp
RUN dpkg -i /tmp/cudnn-local-repo-ubuntu2004-8.3.2.44_1.0-1_amd64.deb && \
    apt-key add /var/cudnn-local-repo-ubuntu2004-8.3.2.44/7fa2af80.pub && \
    apt-get update && \
    apt-get install -y libcudnn8 libcudnn8-dev libcudnn8-samples && \
    rm /tmp/cudnn-local-repo-ubuntu2004-8.3.2.44_1.0-1_amd64.deb

# Build and install OpenCV with CUDA support
WORKDIR /opencv
RUN mkdir build && cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D WITH_CUDA=ON \
          -D WITH_CUDNN=ON \
          -D WITH_CUBLAS=ON \
          -D WITH_TBB=ON \
          -D OPENCV_DNN_CUDA=ON \
          -D OPENCV_ENABLE_NONFREE=ON \
          -D CUDA_ARCH_BIN=7.5 \
          -D OPENCV_EXTRA_MODULES_PATH=/opencv_contrib/modules \
          -D BUILD_EXAMPLES=OFF \
          -D HAVE_opencv_python3=ON \
          .. && \
    make -j $(nproc) && \
    make install && \
    ldconfig && \
    ln -s /usr/local/lib/python3.8/site-packages/cv2 /usr/local/lib/python3.8/dist-packages/cv2

# Clean up
WORKDIR /


RUN rm -rf /opencv /opencv_contrib

# Set the default command to bash
CMD ["bash"]

RUN mkdir /talha 
WORKDIR /talha
