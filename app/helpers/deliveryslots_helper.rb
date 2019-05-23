module DeliveryslotsHelper
  def check_timeslots(date)
    @alltimeslots = [1,2,3,4,5,6,7]
    @slotstaken = Deliveryslot.where(date: date).where(taken: 2).map {|x| x.timeslot_id} if Deliveryslot.all.present?
    @available_timeslots = @alltimeslots - @slotstaken
  end
end
