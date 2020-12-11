package manager
{
    import laya.events.Event;
    import laya.net.Socket;
    import laya.utils.Byte;
    import laya.utils.ClassUtils;

    import proto.ProtoObject;

    public class WebSocketManager
    {
        private static var _instance:WebSocketManager;
        private var socket:Socket;
        private var connetUrl:String;
        private var timeOut:Number;
        private var _mainResLoadComplete:Boolean = false;
        private var _msgCache:Array = [];
        private var _receiveMsg:Boolean = false;

        public function WebSocketManager()
        {
            socket = null;
            connetUrl = null;
            timeOut = 6;
            Laya.timer.loop(1000, this, connectTimeOutCheck);
        }

        private function connectTimeOutCheck():void
        {
            if (this.socket && !this.socket.connected)
            {
                if (timeOut > 0)
                {
                    timeOut -= 1;
                    if (timeOut <= 0)
                    {
                        close();
                    }
                }
            }
        }

        public static function get instance():WebSocketManager
        {

            return _instance || (_instance = new WebSocketManager());
        }

        private var _protoObject:ProtoObject = new ProtoObject();


        public function send(id:int, msg:*):void
        {
            if (this.socket && this.socket.connected)
            {
                var protoMsg:ProtoObject = _protoObject;
                protoMsg.id = id;
                protoMsg.a = msg;

                this.socket.send(JSON.stringify(protoMsg));
            }
        }

        public function sendMsg(msg:*):void
        {
            if (this.socket && this.socket.connected)
            {
                this.socket.send(JSON.stringify(msg));
            }
        }

        public function close():void
        {
            if (this.socket)
            {

                this.socket.off(Event.OPEN, this, openHandler);
                this.socket.off(Event.MESSAGE, this, receiveHandler);
                this.socket.off(Event.CLOSE, this, closeHandler);
                this.socket.off(Event.ERROR, this, errorHandler);
                this.socket.close();
                this.socket = null;
                GameEventDispatch.instance.event(GameEvent.WsClose);
            }
        }

        public function isConnect():Boolean
        {
            if (this.socket)
            {
                return this.socket.connected;
            }
            return false;
        }


        public function connect(url:String, login:Number = 1):Socket
        {
            if (this.socket && url === this.connetUrl)
            {
                return this.socket;
            }
            connetUrl = url;
            this.socket = new Socket();
            timeOut = 6;
            this.socket.endian = Byte.BIG_ENDIAN;
            this.socket.connectByUrl(url);
            this.socket.on(Event.OPEN, this, openHandler);
            this.socket.on(Event.MESSAGE, this, receiveHandler);
            this.socket.on(Event.CLOSE, this, closeHandler);
            this.socket.on(Event.ERROR, this, errorHandler);

            return this.socket;
        }


        private function openHandler(event:Object = null):void
        {
        }


        public function isMainResLoaded():Boolean
        {
            return _mainResLoadComplete;
        }

        public function mainResLoadComplete():void
        {
            _mainResLoadComplete = true;
            var protoMsg:ProtoObject

            if (isConnect())
            {
                for (var i:int = 0; i < _msgCache.length; i++)
                {
                    protoMsg = _msgCache[i] as ProtoObject;
                    GameEventDispatch.instance.event(String(protoMsg.id), protoMsg.a);
                }
            }

            _msgCache.length = 0;
        }


        private function receiveHandler(msg:Object = null):void
        {
            if (msg instanceof Object)
            {
                var uintArr = new Uint8Array(msg)

                var id = (uintArr[0] << 16) + (uintArr[1] << 8) + uintArr[2]
                //                var code = (uintArr[3] << 8) + uintArr[4]

                var class_name:String = 's2c_' + id

                var pobj = ClassUtils.getClass(class_name)

                var data_arr = uintArr.subarray(3)

                var obj = pobj.deserializeBinary(data_arr)

                GameEventDispatch.instance.event(String(id), obj);

            } else
            {
                var protoMsg:ProtoObject = JSON.parse(String(msg)) as ProtoObject;
                if (!protoMsg.id)
                {
                    for (var key:String in protoMsg)
                    {
                        protoMsg.id = key;
                        protoMsg.a = protoMsg[key];
                        if (protoMsg.a is Array ||
                                protoMsg.a is Number)
                        {
                            protoMsg.a = {p: protoMsg.a}
                        }
                        break;
                    }
                }
                _receiveMsg = true;
                if (protoMsg)// && (msgDispatch || protoMsg.id == 8))
                {
                    if (!_mainResLoadComplete && "8" != protoMsg.id)
                    {
                        _msgCache.push(protoMsg);
                    } else
                    {
                        GameEventDispatch.instance.event(String(protoMsg.id), protoMsg.a);
                    }
                } else
                {
                }
            }

        }

        private function closeHandler(e:Object = null):void
        {
            //关闭事件
            if (this.socket)
            {
                this.socket.off(Event.OPEN, this, openHandler);
                this.socket.off(Event.MESSAGE, this, receiveHandler);
                this.socket.off(Event.CLOSE, this, closeHandler);
                this.socket.off(Event.ERROR, this, errorHandler);
                this.socket = null;
                GameEventDispatch.instance.event(GameEvent.WsClose);
            }
        }

        private function errorHandler(e:Object = null):void
        {
            //连接出错
            if (this.socket)
            {
                this.socket.off(Event.OPEN, this, openHandler);
                this.socket.off(Event.MESSAGE, this, receiveHandler);
                this.socket.off(Event.CLOSE, this, closeHandler);
                this.socket.off(Event.ERROR, this, errorHandler);
                this.socket = null;
                GameEventDispatch.instance.event(GameEvent.WsError);
            }
        }
    }
}
