//
//  YDDpcmTOwav.m
//  Yddworkspace
//
//  Created by ispeak on 2018/1/9.
//  Copyright © 2018年 QH. All rights reserved.
//

#import "YDDpcmTOwav.h"

@implementation YDDpcmTOwav

// wav头的结构如下所示：
typedef struct {
    char riffType[4]; //4byte,资源交换文件标志:RIFF

    int32_t riffSize; //4byte,从下个地址到文件结尾的总字节数

    char waveType[4]; //4byte,wav文件标志:WAVE

} HEADER;

typedef struct {
    char formatType[4]; //4byte,波形文件标志:FMT(最后一位空格符)

    int32_t formatSize; //4byte,音频属性(compressionCode,numChannels,sampleRate,bytesPerSecond,blockAlign,bitsPerSample)所占字节数

    int16_t compressionCode; //2byte,格式种类(1-线性pcm-WAVE_FORMAT_PCM,WAVEFORMAT_ADPCM)

    int16_t numChannels; //2byte,通道数

    int32_t sampleRate; //4byte,采样率

    int32_t bytesPerSecond; //4byte,传输速率

    int16_t blockAlign; //2byte,数据块的对齐，即DATA数据块长度

    int16_t bitsPerSample; //2byte,采样精度-PCM位宽

} FMT;

typedef struct {
    char dataType[4]; //4byte,数据标志:data

    int32_t dataSize; //4byte,从下个地址到文件结尾的总字节数，即除了wav header以外的pcm data length
} DATA;

// pcm文件路径，wav文件路径，channels为通道数，手机设备一般是单身道，传1即可，sample_rate为pcm文件的采样率，有44100，16000，8000，具体传什么看你录音时候设置的采样率
int convertPcm2Wav(char* pcm_file,
                   char* wav_file,
                   int   channels,
                   int   sample_rate) {
    int bits = 16;
    //以下是为了建立.wav头而准备的变量
    HEADER         wavHEADER;
    FMT            wavFMT;
    DATA           wavDATA;
    unsigned short m_pcmData;
    FILE *         fp, *fpCpy;
    if((fp = fopen(pcm_file, "rb")) == NULL) //读取文件
    {
        printf("open pcm file %s error\n", pcm_file);
        return -1001;
    }
    if((fpCpy = fopen(wav_file, "wb+")) == NULL) //为转换建立一个新文件
    {
        printf("create wav file error\n");
        return -1002;
    }
    //以下是创建wav头的HEADER;但.dwsize未定，因为不知道Data的长度。
    strncpy(wavHEADER.riffType, "RIFF", 4);
    strncpy(wavHEADER.waveType, "WAVE", 4);
    fseek(fpCpy, sizeof(HEADER),
          1); //跳过HEADER的长度，以便下面继续写入wav文件的数据;
    //以上是创建wav头的HEADER;
    if(ferror(fpCpy)) {
        printf("error\n");
    }
    //以下是创建wav头的FMT;
    wavFMT.sampleRate     = sample_rate;
    wavFMT.bytesPerSecond = wavFMT.sampleRate * sizeof(m_pcmData);
    wavFMT.bitsPerSample  = bits;
    strncpy(wavFMT.formatType, "fmt  ", 4);
    wavFMT.formatSize      = 16;
    wavFMT.blockAlign      = 2;
    wavFMT.numChannels     = channels;
    wavFMT.compressionCode = 1;
    //以上是创建wav头的FMT;
    fwrite(&wavFMT, sizeof(FMT), 1, fpCpy); //将FMT写入.wav文件;
    //以下是创建wav头的DATA;  但由于DATA.dwsize未知所以不能写入.wav文件
    strncpy(wavDATA.dataType, "data", 4);
    wavDATA.dataSize = 0;                      //给pcmDATA.dwsize  0以便于下面给它赋值
    fseek(fpCpy, sizeof(DATA), 1);             //跳过DATA的长度，以便以后再写入wav头的DATA;
    fread(&m_pcmData, sizeof(int16_t), 1, fp); //从.pcm中读入数据
    while(!feof(fp))                           //在.pcm文件结束前将他的数据转化并赋给.wav;
    {
        wavDATA.dataSize += 2;                         //计算数据的长度；每读入一个数据，长度就加一；
        fwrite(&m_pcmData, sizeof(int16_t), 1, fpCpy); //将数据写入.wav文件;
        fread(&m_pcmData, sizeof(int16_t), 1, fp);     //从.pcm中读入数据
    }
    fclose(fp);                                   //关闭文件
    wavHEADER.riffSize = 0;                       //根据pcmDATA.dwsize得出pcmHEADER.dwsize的值
    rewind(fpCpy);                                //将fpCpy变为.wav的头，以便于写入HEADER和DATA;
    fwrite(&wavHEADER, sizeof(HEADER), 1, fpCpy); //写入HEADER
    fseek(fpCpy, sizeof(FMT), 1);                 //跳过FMT,因为FMT已经写入
    fwrite(&wavDATA, sizeof(DATA), 1, fpCpy);     //写入DATA;
    fclose(fpCpy);                                //关闭文件
    return 0;
}

- (int)convertPcmToWavWithPCMPath:(NSString*)pcmPath
                          WAVPath:(NSString*)wavPath
                         Channels:(int)channel
                      Sample_rate:(int)sample_rate {
    char* pcmFile = (char*) [pcmPath UTF8String];
    char* wavFile = (char*) [wavPath UTF8String];
    NSError *error = nil;
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:pcmPath] error:&error];
    double sampleRate = audioPlayer.format.sampleRate;
    NSInteger channels = audioPlayer.numberOfChannels;
    
    NSLog(@"pcmdata sampleRate = %f, channels = %ld", sampleRate, (long)channels);

    int code = convertPcm2Wav(pcmFile, wavFile, channel, sample_rate);
    return code;
}

@end
