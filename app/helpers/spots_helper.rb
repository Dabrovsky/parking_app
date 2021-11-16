module SpotsHelper
    def available_spots(parking = {})
        return unless parking.spots.available

        template = "<div class='flex py-1 pl-3 pr-2 rounded-full'>
                        <div class='text-sm text-gray-700 font-normal'>
                            Available Places <span class='h-5 w-5 inline-flex items-center justify-center text-xs text-white font-medium #{parking.spots.available.size <= 2 ? 'bg-red-500' : 'bg-green-500'} rounded-full'>#{parking.spots.available.size}</span>
                        </div>
                    </div>".html_safe
    end
end
