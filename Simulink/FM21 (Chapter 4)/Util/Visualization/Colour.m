classdef Colour
    properties
      R
      G
      B
   end
   methods
      function c = Colour(r, g, b)
         c.R = r; c.G = g; c.B = b;
      end
      function vec = toVector(obj)
         vec = [obj.R/255,obj.G/255,obj.B/255];  
      end
   end
   enumeration
      Red   (100, 1, 1)
      Green (1, 255, 1)
      Blue (1, 1, 255)
      White  (255, 255, 255)
      Gray (128,128,128)
      AgentColour (1,255,255)
      OpponentColour (200,1,1)
   end
end