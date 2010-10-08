# Battle ship
# Setup is based on the court size from http://en.wikipedia.org/wiki/Battleship_(game) 10x10
# and also the amount and size of ships.

module Engine

  class Game

    #Setup ship "aircraft carrier 5" "battleship 4" "destroyer 3" "submarine 3" "patrol boat 2"
    # 50r 24u 15r 94u 89r
    # Will put the ships like this in the matrix
    #
    # There the first number represent the start position
    # on X and the secound number the start Y position.
    # The following character describe the direction the ship
    # will be layed out.
    #
    # r => right
    # d => down
    #
    #   0123456789
    #  0     @@@@@
    #  1  @
    #  2  @      @
    #  3  @      @
    #  4  @      @
    #  5 @@@
    #  6
    #  7
    #  8
    #  9        @@


    def initialize()
      @shipsplayerone = {}
      @shipsplayertwo = {}
      @enginestate = 0
      @playernextaction = -1
      @bombpositions = {}
      @bombpositions[0] = []
      @bombpositions[1] = []
    end

    def setupplayers(inputone, inputtwo)
      return ["EngineWrongState","EngineWrongState"] unless @enginestate == 0

      result = []

      begin
        @shipsplayerone = setupplayer(inputone)
        rescue InputInvalid
          result << "InputInvalid"
        rescue ShipOutOfRange
          result << "ShipOutOfRange"
        rescue ShipOnSamePosition
          result << "ShipOnSamePosition"
        ensure
          result << "" unless result.size == 1
      end

      begin
        @shipsplayertwo = setupplayer(inputtwo)
        rescue InputInvalid
          result << "InputInvalid"
        rescue ShipOutOfRange
          result << "ShipOutOfRange"
       rescue ShipOnSamePosition
         result << "ShipOnSamePosition"
      ensure
        result << "" unless result.size == 2
      end

      if result[0] == "" && result[1] == ""
        @enginestate = 1
        @playernextaction = 0
      end

      result
    end

    def nextmove()

      if @enginestate == 1
        return @playernextaction
      else
        return -1;
      end
      
    end

    def move(player, x,y)

      if @enginestate != 1
        return -1
      elsif player != @playernextaction
        return -2
      elsif x <= 0 && x >= 9 && y <= 0 && y >= 9 #out of game range
        return -3
      else
        placedbombs = @bombpositions[@playernextaction]
        placedbombs << [x,y]

        return -4 unless placedbombs.uniq!.nil?

        result = 0
        shipindexfromhit = checkhit(x,y)

        if shipindexfromhit >= 0
          result = 1
          if (checkifshipsank(shipindexfromhit))
            result = 2
            if (checkifallshipsisdestroyed())
              result = 3
              @enginestate = 2
            end
          end
        end

        setnextplayersmove();
           
        result
      end
    end

    def getbombs(player)
      return -1 unless @enginestate == 1
      return -2 unless (player == 0 || player == 1)

      return @bombpositions[player]
    end

    def getships(player)
      return -1 unless @enginestate == 1
      return -2 unless (player == 0 || player == 1)

      return @shipsplayerone if player == 0
      return @shipsplayertwo

    end

    private

    def checkifallshipsisdestroyed()
      othersships = getopponentsships()
      placedbombs = @bombpositions[@playernextaction]

      othersships.each_value { |ship|

        ship.each { |shippart|
          return false unless placedbombs.include?(shippart)
        }
      }
      return true
    end

    def checkifshipsank(shipindex)
      othersships = getopponentsships()
      placedbombs = @bombpositions[@playernextaction]
      result = true

      shipparts = othersships.values_at(shipindex)[0]

      shipparts.each { |item|
        result = false unless placedbombs.include?(item)
      }
      return result
    end

    def checkhit(x,y)
      othersships = getopponentsships()

      othersships.each_pair { |key, value|
        return key if value.include?([x,y])
      }
      return -1
    end

    def setnextplayersmove()
      @playernextaction = (@playernextaction+1) % 2
    end

    def getcurrentmoversships()
      return @shipsplayerone if @playernextaction == 0
      return @shipsplayertwo
    end

    def getopponentsships()
      return @shipsplayerone if @playernextaction == 1
      return @shipsplayertwo
    end

    def setupplayer(input)

      if (input.respond_to? :join) # If argument looks like an array of lines
        s = input.join # Then join them into a single string
      else # Otherwise, assume we have a string
        s = input.dup # And make a private copy of it
      end

      s.gsub!(/\s/, "") # /\s/ is a Regexp that matches any whitespace

      raise "Ship setup is in the wrong size" unless s.size == 15

      if i = s.index(/[^0123456789ru]/)
        raise InputInvalid, "Illegal character #{s[i,1]} in Game setup"
      end

      #Make sure the input string is formated correctly
      (0...5).each  { |i|        
        raise InputInvalid, "input #{s[i*3]} on position #{i*3} should be an integer" unless s[i*3].index(/[0123456789]/)
        raise InputInvalid, "input #{s[(i*3)+1]} on position #{(i*3)+1} should be an integer" unless s[(i*3)+1].index(/[0123456789]/)
        raise InputInvalid, "input #{s[(i*3)+2]} on position #{(i*3)+2} should be 'r' or 'u'" unless s[i*3+2].index(/[ru]/)
      }

      #Setup the ships in a hash

      ships = {}

      ['aircraftcarrier = 5', 'battleship = 4', 'destroyer = 3', 'submarine = 3', 'patrolboat = 2'].each_index { |v|
        ships[v] = setupship(s[v*3], s[(v*3)+1], s[(v*3)+2], (5-(v >= 3 ? v-1 : v)))
      }

      #Check that the ships are setup in a valid way
      checkshipspossition(ships)

      ships

    end

    def checkshipspossition(ships)

      allshippositions = []

      ships.each_value {|ship|
        ship.each {|part|
          raise ShipOutOfRange, "Ships is outside battle field borders" unless (0..9).include? part[0]
          raise ShipOutOfRange, "Ships is outside battle field borders" unless (0..9).include? part[1]

          allshippositions << part

        }
      }
      
      raise ShipOnSamePosition, "Ship on same position" unless allshippositions.uniq! == nil

    end


    def setupship(x, y, direction, size)

      result = []

      case direction
      when "r"
        (0...size).each {|row| result[row] = [x.to_i+(row), y.to_i]}
      when "u"
        (0...size).each {|col| result[col] = [x.to_i, y.to_i-(col)]}
      end
      result
    end

  end

  class InputInvalid < StandardError
  end

  class ShipOutOfRange < StandardError
  end

  class ShipOnSamePosition < StandardError
  end

end