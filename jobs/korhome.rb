require 'net/http'
require 'json'

# authenticate
ip_address = "hue_ip_address"
http             = Net::HTTP.new(ip_address, 80)
username = "<hue_username>"
request = Net::HTTP::Get.new('/api/'+username+'/lights')

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '20s', :first_in => 0 do |job|
  response = http.request(request)
  response = JSON.parse(response.body)
  index = 0
  for i, light in response
    index += 1
    name = light["name"]
    light = light["state"]
    if light["colormode"] == "xy"
      #convert from xy to rgb
      x = light["xy"][0]
      y = light["xy"][1]
      z = 1.0 - x - y
      brightness = 200
      print "brightness is " + String(brightness)
      final_x = (brightness / y) * x
      final_z = (brightness / y) * z
      r =  (String(final_x * 1.656492 - brightness * 0.354851 - final_z * 0.255038).split "." )[0]
      g = (String(-final_x * 0.707196 + brightness * 1.655397 + final_z * 0.036152).split "." )[0]
      b =  (String(final_x * 0.051713 - brightness * 0.121364 + final_z * 1.011530).split "." )[0]
      color = "rgb(#{r},#{g},#{b})"
    else
      print light["hue"]
      #convert from philips hue to hsl
      hue = (String((light["hue"]*360)/65535))
      sat = String(light["sat"]*100/255)
      bri = String(100*200/255)
      color = "hsl("+hue+","+sat+"%,"+bri+"%)"
    end
    send_event('korhome-light-'+String(index), { hue_id:i, light_name: name,  bg_color: color})
  end
end
