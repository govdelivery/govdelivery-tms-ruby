#
# Before saving, recipient tries to properly format the 
# provided phone attribute into the formatted_phone attribute. 
#
# A recipient without a formatted_phone is one that we 
# cannot possibly forward on to the third-party provider. 
#
module Recipient
  extend ActiveSupport::Concern

  included do
    attr_accessor :skip_message_validation
    
    belongs_to :message, :class_name => self.name.gsub('Recipient', 'Message')
    belongs_to :vendor, :class_name => self.name.gsub('Recipient', 'Vendor')

    scope :to_send, -> vendor_id { {} }
    scope :incomplete, where(status: RecipientStatus::INCOMPLETE_STATUSES)
    scope :most_recently_sent, order('sent_at DESC').limit(1)

    attr_accessible :message_id, :vendor_id, :vendor
  end

  def sending!(ack, *args)
    update_status!(RecipientStatus::SENDING, ack)
  end

  def sent!(ack, date_sent=nil)
    update_status!(RecipientStatus::SENT, ack, completed_at: date_sent)
  end

  def failed!(ack=nil, error_message=nil, completed_at=nil)
    update_status!(RecipientStatus::FAILED, ack, error_message: error_message, completed_at: completed_at)
  end

  def canceled!(ack, *args)
    update_status!(RecipientStatus::CANCELED, ack)
  end

  def blacklist!
    self.status = RecipientStatus::BLACKLISTED
    self.save!
  end

# DDNDDNNNND8D888D8888888O8888O8OOOOZZ$$$777IIII????+++===~~~::,,,,,::~~:::::,,,:,,..... . .  .   ..   ....      
# . .. .               . . ..  . ..     .  ..    ... ..     .... ..  .      .       .        ...    .  .     ... 
#                               ..+$ZO$$$I,.   .                                                                 
#                           . ~N87,.  .    ,788Z~. .    .  ..                                                    
#                         . $8+      .  .    . . 7DD8DD88OZ+.                                                    
#                      .  ?8=                     $..= .    ?D8I .                                               
# ~~~:~~::::::,,,,,......I8.                    .+    .Z . . ..=88=,,,,.,,,,,:,::::,,:,,,:,,,,,,,,:,,,,,,,,,:,,,,
#  .         . .     . .88 .                    ..   ..  O~~I,    .8$    . .             ....    .   .         . 
#                     .O8 ..  ..              ..~.       .7,  .   ..7O..                                         
#                    .88.. . .:                I. .      ...      ....8$.                                        
# ,,... . . ..    .  8O.  ..7?,7?   .      .. ?.            I8O$~  .+77$8~...  .        ....   .       .  .      
# DNNDNNNNNDNDDNNNDND, ..  ?      ~?77I=+?III        .. .  I  $$,  .    .ZDNNDODDNDDDDDNNNNNDNNDDDDNDDDDDDDDDDDDD
# DNNNNNNNNNNDNDDDDD  ...7          . ...    .          =7 .   .  :.   ..  =DD:DNDNNNNNNNNNNNNNNNNNNDNNNNNNNNNNNN
# NNNDNNNDNNND. .DD ..=Z. .                 .....7$+:..            ..        ZDDDD7:NNDNNNNNNNNNNNNNNNNNNNNNNNNNN
# NNNNNNDNNNNDDDDD.O+..   I:                 .?        .            .       ..=DDN  ,DNNDNNNNNNNNNNNNNNNNNNNNNNNN
# NNNNNDDNNNNDDDD7 .        .7           . ?: .                             . . DDNDN$NNNNNNDNNDONNNNNNNNNNNNNNN:
# I8NDNDDNNDDDO=.           . ~ .     .  +,           .      . ... ..~?77I=:~=I$$DDNNNNN8NNNNNNNNNNNNNNNNNNNNNDN 
# NNDNNNDNDNZ  . .          .. .       .~.            .      .  ~I.     .   .    .DDDNNNNN8NNNNNONNNNNNNNNNNNNNNN
# NDNND8NN8... ..              =    ...,                     :~ .          .     . +DNNNDNNNNNNNNNNNNNNNNNNNNNNNN
# NNNDNNN8. $~                 7.    ....                   +.  .          ?     .. .DDNNNNNDNNNNNNNNNNNNNNNNNNNN
# NNNDNN8  ..               .. $         $.               $               $.. .    ..+DNNNNNNNNNDNNNNNNNNNNNNNNNN
# NNNNID$               . ...$            ?  . ....  . ?,..            ~.   ..,        DNNNNNNNNNNNNNDNNZNNNZNNNN
# .NNDDND.               ~?.               .$: ...,I$...             I ...              ODNNNINNNNNN8NNNNNDNNNNDN
# NNNNDN  +. . ...  .I= ..                    ..                .. 7              ..    .DNNNNNNNNNNNNNNNNNNDNMN$
# NNNDD7  .. I~...+~...  .                  .   ..,             . $.            .=..     =DNNNNNNNNNNNNMNNNNNNNND
# N. DD.       .                         :     .:            . .?                :~:..... ONNNNNDNNNNNNNMNNNNNNDN
# MNNDM                                ?.     .$        .   ..=       ..  .=+ .         =? DDNNNNNNNNNNNNNNNNNDNN
# NNNDN.                              :.     ..           .+. .        =~ ....      ?.. ...=DNNNNNNNDNNNNN8NNNNNN
# NDNDO.                             +     ..,.        .~~        .  7. .               .   ?DNNNNNNN8NDDNNNNNNDN
# N DDII .   .                    . Z. ..  $ .       I~.  ....   .7,             ...  =.. .  ODDNNNNNNNNNNNNDNNNN
# NNND+.,~...                    . I .   $         .  .,.....  .  .             .,=II~~Z777$$?8NNNNNNNNNNNNNNNNNN
# NNN8I   .+..                 ...+.  ,OI$Z$7=                               .,~               DNDNNNNNDNNNNNNNNN
# NNN88.    .7                 ..I.,OO? .+?.=$ODO..                         ,.                 .8NNNNDNON8NNNDNNN
# NNNDD.      I  ..~            :$88Z. ..:.78O.. +O7   .               ?. .7  .               .  DNNNDNNNNNN7..NN
# NNDDD.     . $    . ..       :8OO .=???..=. 7 =:  IO. ..           .  .~                       .8NNDNNNNN7NNNNN
# NNNDDO..   . . ...=,. .      88=ODZ~ .,?Z..I. .?.,I,:O=..          . 7 .               . . ,$II$8DNNNNMNNNNNNNN
# NNNNDD.        =. 7=, I$.   O8Z,..   .7~, ~~.=. .:.,.I OI .        .I  .. ... .    .~$I..      ..$DDDNNNNNNNDNN
# NNNNN88.     .. $ :,I+I .. D8+,  .~+ZDN:.  +I.,...   ,   O=        . ...?++++: . .    . ..      ..8DD8NNMNNNNNN
# NNNDDDDD...     .  ,. .  78         . . ZOZ .~. ,..=..    ,8 .                                   ......8NNNNNNN
# NNNNDNDDD .      +.I+$. 8I    .  .     . . :D .? .$  . .   =,8,.                                 . $, . DNDNNNN
# DNNNNDNNNN       + .+.  O.  .+8=. ..=ZO: . .  Z ,  ,  . .    ,=?                                   ?.?: O8NNNNN
# NNNDNDNNND:..   .I..I..,...8+ .. ...+DDDD8  . IZ 7.. : .. :.. ~ 8 .. . ...       .             .    +~=.8NNNNNN
#  .DNDNNDNNN7.    I...O.Z $Z. :O~.~7ONDDDND8D    $ ~. .   .I ~  +  OO88O?     . =,               . . ::+.~DNNNNN
#  NNNNNNNOZNDD  .., :. ~N 8..$ .    . DDDNDDDD. ..:.$ .  . ,.. ..  Z7  .  ZZ:.       .            $Z.O,+?.DONNNN
# NNNNNNNNND$NDN ..: :  .D.? .$.      .IDDDDDDDZ.  I. 7..... ?. =.+$I...  .. .~8:. .             .,=. :.88:DNNNNN
# NNNNNNNNNNNDNNN+ ,  + .8~... Z       DDDNNNND,8... .~  = . .  ~ =8   .   .. ...$I               7 , =  88DNNDNN
# NNNNMMDNNNNNDDDDD~...: ?7I   ..~7D8NDDDDDDDDO =,. ..  ... .?   ..8    ..  .   .77IO   .     .. .Z$..8,~.NNNNDNN
# NNNNNNNN,8NNNNNNDD.. ++.8$ .     .88DDDDDDD8..,~.. ,.  , ..Z  .  = ..     ..?+. ..+:OZ~ ....  .:I 8, .$  DNNNND
# NNNNNNNNNNNNNDNDNDD   ZIDIO..   7..=ODDD8OO.. 8..  =. .  ..I~  7.  ..     .Z.,., .$=. ~$88ZO~,    O8O...ODNNNNN
# NNNNNNNNNNN .=DON$N8:  $=N7I.   ZIZ.  ..    .8   ?.? + . ==7I :I:. =. . . $  =.OO8 .           , . D8Z,.,DNNNNN
# NNNNDNNNDNNDMNNDDNNNNNDIZDN.D  .  ..   .  .8I,7:7?  +.  .. ,?. ==  . . ..~ ~$8DDZ.:..           ?7.,88O~ ONNNNN
# NNNNNNNNNNNNNNDDZ.Z:O$$D88DN+.?$:  . .~O$   $.,? .~~ .. :?$ .   7..   ~, .$8DDDZ... .,    ...   .:7=.ZD7 ?DDNNN
# NDNDNNNMNNNND=.   .:.II=O?.O788.       ...$ ,~  Z     =.7$.,    I:.  .7 :ZODDOI  .?    .=$$$I+7ZZIOZ . D,+NNDNN
# NNNNNNNNNNNDD      8,ZNNND+$ $8DD88888I .. I.==  7..==..O ,  .:$+,  .7  888Z  7.?.+  +.  ..  ......  $ .7+DNNNN
# NNNNNNNNDNNNN. .   .DDNDDDD8,I=NDDD77ZO8D8Z~ .~: +8 .$==Z  ...$.  ZZ7..O8.   .~,I.:+ .  :.?$Z8DDDOI.~:~I.8DNNN8
# NNMNNNNNDNDND7 .  .. NDNDDDNNMNDNDND8OO+$OD8DD7  .:+O$=  ?.~ ., .$ .+.Z   .  .?.7.?  .=8DNDDDDDDDDDD8I?=.ZNNN~N
# MNNNNNNNDNNDD.$      .?DNDDDNNM+ ~D,Z.=8OD88D88D8$= ...,  : .7 :=  7.=:I. +~.$ .  ? ZDDDDDNDDDDDDDDD8I+8 :NDN8N
# NNNNNNNNNNNND  8.     .7DNDDNDD O .N. ~D D .N.8 O  ~ ~ ?..  .~ +..,.~...  I. .   .$NNDDDDDDNDDDNDDDND,:8~.NNDNN
# NDNNNNNNNNND?.  +.      ZDDDD8I~Z: $~Z..7=I+.N.Z.$   ..?,. .? O  .=.. =...  . ,ZDNDNDDDD8Z8877Z7$ZZ87$NN7:NNNNN
# NNNNNNNNINND     $  .    .DNDD~8 I?.D..I, N ..D,  +   ,~7: .=+ + ?.   ZOZDD8NNNDNDDO++  .  ~~.  .  7. DNO?NNNND
# NNNNNNNN.ND$      +..     .DND$N.~?:$ ?: 7~8~ IN.++ .7, : ..+ OI=7?Z~Z==~~==+:,.:...   .    ..    . . ON8$NNDNN
# ,MNNNNNDNDD.      ..?.      ,DNO8 $,:=$=: 7$Z. 7.8..+$.,  IZ,.:   :   .. :..   ..     ..,+O8OO88888Z?=DNDDNNNND
# M8NNMNDNDD        .. D..      8DDZ=+.I $ ,,. O.+.~ :8.+?=  $.,O?=... .     .  .~?$O8OOO?.$I.  .=    .DNNDDNDNNN
# ZD8NNDNDD.        .  .I,.     .$NNO8 $+.Z.I7$ 7 I ..O.$=:.:.ZI~,?~   ?88OO8OZ7ZO$+ ~..O :.~,~ ? =~ $.8DNNNNNNDN
# NNNDNNND             . .+.      .DNO :, ,.,+Z, :. O:+7 O .O: ,....:. . +II7O$~...   . $.,,~7$ +D8 .=~DNNNNNNNND
# NNDNND$   .           ..+7   . .. DNII7.~O=:.7 +,. O.~.D.+?.,Z~??, ... ..,~.~,~..,. .?Z.~$+.$ 8DN ~~8NNNNNNNNNO
# NDDD$ .                   8.       ON.+8  ZI=., =.ZO~,,$ $?, I.  ~$7     .+$7+Z .7,  ,O.7 Z Z.8DD Z:DDDN 7NNNNN
# DDZ  .                     ~+       .D .I.,: ,.+7 .~7.~:.+I .:$~.~.7?:. O. Z  ?.:7,.$ZO,$O$.O,DDN.8ZNNNNNNNN8NN
# .. . .                       Z       .D?~:7Z ?~.7.$$:I$ Z.I  ,? ..O  .~:O $$$++.7Z..,.Z:ZZ8=O~NND 8DNNNNNNNDNNN
#               .              .+ ..   ..INZ,+D.,I.:,Z..O,? + .?..  7$.. =O $?$$$ 7O II.8?ZDZ?8INND.NNN8~NNNNNNNN
#                                ,+. .   . DD$.N .7I.=.7?I ?7 ,7: .?~ .   $ :.   .Z= ? =8$ZIZ7D8ZN8INNNNINNNDDNNN
#                                . $ .   . ..DO.D.?.I..ZZ,$..= ?~. =7, .. 8?  ... IO7.?O88O+7=ODNN8DNNNNNNNNNNNNN
#                                    $.       ZD+8.: .Z. Z. 7  .I ,.?+=.. $7 .~Z, :78?DD8OZ~= 8DNN8NNNNNN$MNNDNND
#                                   ..=        .NDD I ,=7 .,:  +,..  I7~,.+~. ~IZ+ .O8DDD8~ : =+DNDNNNNNN$NNNNNNN
#                                      += .      IDD=:..=+$ ..I   ?:   .. $.~$?7 $.$IODDDZ  . ..?NNNNNNNNNNNNNNNN
#                                              ___       ______  __  ___
#                                             /   \     /      ||  |/  /
#                                            /  ^  \   |  ,----'|  '  / 
#                                           /  /_\  \  |  |     |    <  
#                                          /  _____  \ |  `----.|  .  \ 
#                                         /__/     \__\ \______||__|\__\
#                             ____    __    ____  ___      .______          _______.
#                             \   \  /  \  /   / /   \     |   _  \        /       |
#                              \   \/    \/   / /  ^  \    |  |_)  |      |   (----`
#                               \            / /  /_\  \   |      /        \   \
#                                \    /\    / /  _____  \  |  |\  \----.----)   |
#                                 \__/  \__/ /__/     \__\ | _| `._____|_______/


  def ack!(ack=nil)
    update_status!(nil, ack)
  end

  def update_status!(status, ack=nil, opts={})
    raise "#{self.class.name} #{self.id} is already complete" if RecipientStatus.complete?(self.status)
    self.vendor ||= message.vendor
    self.ack ||= ack
    self.status = status if status
    self.completed_at = opts[:completed_at] || Time.now if RecipientStatus.complete?(status)
    self.error_message ||= opts[:error_message]
    self.save!
  end


end
