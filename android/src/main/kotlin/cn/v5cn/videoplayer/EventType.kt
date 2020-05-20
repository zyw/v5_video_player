package cn.v5cn.videoplayer

enum class EventType {
    //准备完成事件
    PLAYER_EVENT_PREPARED,
    //视频播放失败事件
    PLAYER_EVENT_FAIL,
    //分辨率发生变化
    PLAYER_EVENT_SIZE_CHANGED,
    //首帧渲染显示事件
    PLAYER_EVENT_RENDERING_START,
    //开始自动播放
    PLAYER_EVENT_AUTO_PLAY_START,
    //缓冲位置
    PLAYER_EVENT_BUFFERED_POSITION,
    //当前播放位置
    PLAYER_EVENT_CURRENT_POSITION,
    //循环播放开始。
    PLAYER_EVENT_LOOPING_START,
    //拖动完成
    PLAYER_EVENT_SEEK_COMPLETE,
    //播放状态改变
    PLAYER_EVENT_STATE_CHANGED,
    //截图事件
    PLAYER_EVENT_SNAP_SHOT,
    //loading开始
    PLAYER_EVENT_LOADING_BEGIN,
    //缓冲进度
    PLAYER_EVENT_LOADING_PROGRESS,
    //loading结束
    PLAYER_EVENT_LOADING_END,
    //视频播放完成
    PLAYER_EVENT_COMPLETION,
}