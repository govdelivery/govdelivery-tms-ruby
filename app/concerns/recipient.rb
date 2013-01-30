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
    belongs_to :message, :class_name => self.name.gsub('Recipient', 'Message')
    belongs_to :vendor, :class_name => self.name.gsub('Recipient', 'Vendor')

    scope :to_send, -> vendor_id { {} }
    scope :incomplete, where(status: RecipientStatus::INCOMPLETE_STATUSES)

    attr_accessible :message_id, :vendor_id, :vendor
  end

  def sending!(ack)
    update_status!(RecipientStatus::SENDING, ack)
  end

  def sent!(ack)
    update_status!(RecipientStatus::SENT, ack)
  end

  def failed!(ack=nil, error_message=nil)
    update_status!(RecipientStatus::FAILED, ack, error_message)
  end

  def canceled!(ack)
    update_status!(RecipientStatus::CANCELED, ack)
  end

  def blacklist!
    self.status = RecipientStatus::BLACKLISTED
    self.save!
  end

  #             _    _
  #   __ _  ___| | _| |
  #  / _` |/ __| |/ / |
  # | (_| | (__|   <|_|
  #  \__,_|\___|_|\_(_)
  #
  #                         . -, .-=- -: -=-._- .
  #                      .<!~:!!~`- :~.e@bbu <.t`\.`.
  #                  :~:!!`.!!~.>.>~e$$$$$$$$o/< !.`i`
  #                :~.!!~:!!~.!`/~u$$$$$$$$$$$$c4! !.!.`.
  #              .!~<!~:!!!~<f.~z$$$$$$$$$$$$$$$c~!:`:`t i
  #            ~:! <!~<!!!.!~:`@$$$$$$$F`?`?$$$$$b`!h`h'! <
  #           ~<! !!`<!!~.!~< $F,F,$$F d$ $b ?$h`E\'!h'! ! \
  #         .~<! !!~<!!~:!-<`@$:$:$$$ d$$ $$b B$b:tL~!:`! !:~:
  #         ~:! !!~:!!f:!~<!x$$h?h?$$ F ? F ? 4$fdf,c!! 4!'!:~!
  #        / X !!!.X!! ?~:! $$$$$$$$$ ?eP ?eP d$$$$$$ !! S!'!:`:
  #       : !f:!% XXX~!~:!X $$$$$$$$$beed$beed$$$$$$$k?!:`!h`7>?h
  #       ! X !!!:X!! ~:!!!:$$$$$$$$$$$$$$$$$$$$$$$$$B'M! X!:`X Xh
  #      <><!'!!>XM! ~<!~``'$$$$$F"??$$$$$$$$?"?$$$$$ #~!'!! ?!'M:
  #      ? Xf<UX H!f <Sfz$$e$$$$$b$$bccccccccd$$$$$$$$i@$c TH%'!>?7
  #      ! X X!H MS~!!!>?$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ )!?:%!`!:
  #      ? % @!S !. !!!!> "?$$$$$$$$$$$$$$$$$$$$$$$$$$$"")!'!?!'! X!>
  #     <X ! XMX .! ?!F.$"><."??$$$$$$$$$$$$$$$$$$$P*?. @.!:`!! X>!X\
  #     )! ! !M\ X! !! $P.)~!,`L.Z. ")Z???ICCC"! :<X !!:9$/!h`4h'! !!
  #     !*'!X'.! XX ~)u.f>.`!`!! :) $$$$$$$$$F47X !!h`!!/#\!!!:` !!'!!
  #    J%!'%#:HX'SM'''`'":  " `". ` ?$$$$$$$$>"~)L``! ~~~-'XXX!.` 4!x`4:.
  #   :!? <! /S('!!',cd$$$$$e $$$$b :$$$$$$$$ 9$$P e$$$$$$$eu"!!L`:`!!x'!h
  # ,S,XX.! .!H>4?T'$$$$$$$$$b`$$$f `$$$$$$$f:'$$ d?$$$$$$$$$$L"!L)S:~XX 2
  # X X! X~:HX".RX'$$$$$$$$ eee$$$'eeeeeeeeeee 4$eee $$$$$$$$$$b f<XX:`~ `
  #     '  `'` fd d$$$$$$$$.?$$$$F,$$$$$$$$$$$,?$$$$ $$$$$$$$$$$$c`!H>

  def ack!(ack=nil)
    update_status!(nil, ack, nil)
  end

  def update_status!(status, ack=nil, error_message=nil)
    raise "#{self.class.name} #{self.id} is already complete" if RecipientStatus.complete?(self.status)
    self.vendor ||= message.vendor
    self.ack ||= ack
    self.status = status if status
    self.completed_at = Time.now if RecipientStatus.complete?(status)
    self.error_message ||= error_message
    self.save!
  end


end
