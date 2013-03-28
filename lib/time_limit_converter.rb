class TimeLimitConverter
  class << self

    # convert seconds to hours
    # 4000 => 1.11
    def to_hours(sec)
      (sec.to_f / 3600).round(2)
    end

  end
end
