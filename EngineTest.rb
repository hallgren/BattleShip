# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'Engine'

class NewClassTest < Test::Unit::TestCase
  
  def test_can_return_correct_class

    a = Engine::Game.new()
    a.setupplayers("50r 24u 15r 94u 89r", "50r 24u 15r 89r 89r")
    assert_equal(Engine::Game, a.class)
  end

  def test_can_return_expected_player_move

    a = Engine::Game.new()
    assert_equal(-1, a.nextmove)
    a.setupplayers("50r 24u 15r 94u 89r", "50r 24u 15r 94u 89r")
    assert_equal(0, a.nextmove())

  end

  def test_cant_setup_players_in_wrong_engnie_state
    a = Engine::Game.new()
    result = a.setupplayers("50r 24u 15r 94u 89r", "50r 24u 15r 94u 89r")
    assert_equal(Array, result.class)
    result = a.setupplayers("50r 24u 15r 94u 89r", "50r 24u 15r 94u 89r")
    assert_equal(Array, result.class)
    assert_equal("EngineWrongState", result[0])
  end

  def test_can_change_player_turn_during_game
    a = Engine::Game.new()
    a.setupplayers("50r 24u 15r 94u 89r", "50r 24u 15r 94u 89r")
    moveresult = a.move(0,3,4)

    assert_equal(0, moveresult)
    assert_equal(1, a.nextmove)

    moveresult = a.move(1,8,9)

    assert_equal(1, moveresult)

  end

  def test_can_get_same_players_turn_on_wrong_input_move
    a = Engine::Game.new()
    a.setupplayers("50r 24u 15r 94u 89r", "50r 24u 15r 94u 89r")

    a.move(1,30,40)

    assert_equal(0, a.nextmove)

  end

  def test_can_sink_ship
    a = Engine::Game.new()
    a.setupplayers("50r 24u 15r 94u 89r", "50r 24u 15r 94u 89r")
    moveresult = a.move(0, 8, 9)
    assert_equal(1, moveresult)
    a.move(1,4,5)
    moveresult = a.move(0, 9, 9)

    assert_equal(2, moveresult)

  end

  def test_can_sink_all_ships_player_one_wins
    a = Engine::Game.new()
    a.setupplayers("50r 24u 15r 94u 79r", "50r 24u 15r 94u 19r")

    result = false

    (0..9).each { |x|
      (0..9).each { |y|
        
        if a.move(0,x,y) == 3
          result = true
          assert_equal(-1, a.move(1,x,y))
          break
        end

        a.move(1,x,y)

      }
      if result
        break
      end
    }

    assert_equal(true, result)

  end

  def test_can_sink_all_ships_player_two_wins
    a = Engine::Game.new()
    a.setupplayers("50r 24u 15r 94u 79r", "50r 24u 15r 94u 89r")

    result = false

    (0..9).each { |x|
      (0..9).each { |y|

        a.move(0,x,y)
      
        if a.move(1,x,y) == 3
            result = true
          break
        end

      }
      if result
        break
      end
    }

    assert_equal(true, result)

  end

  def test_can_get_correct_bomb_positions
    a = Engine::Game.new()
    a.setupplayers("50r 24u 15r 94u 79r", "50r 24u 15r 94u 89r")

    a.move(0,0,0)
    a.move(1,1,1)
    a.move(0,2,2)
    a.move(1,4,5)
    a.move(0,5,6)

    assert_equal([[0,0],[2,2],[5,6]], a.getbombs(0))
    assert_equal([[1,1],[4,5]],a.getbombs(1))

  end

  def test_can_get_correct_ship_positions
    a = Engine::Game.new()
    a.setupplayers("50r 24u 15r 94u 79r", "50r 24u 15r 94u 89r")

    shipsplayerone = a.getships(0)

    shipsplayerone.each_with_index { |value,i|
      case i
      when 0
        assert_equal([[5, 0], [6, 0], [7, 0], [8, 0], [9, 0]], value[1])
      when 1
        assert_equal([[2, 4], [2, 3], [2, 2], [2, 1]], value[1])
      when 2
        assert_equal([[1, 5], [2, 5], [3, 5]], value[1])
      when 3
        assert_equal([[9, 4], [9, 3], [9, 2]], value[1])
      when 4
        assert_equal([[7, 9], [8, 9]], value[1])
      end
    }
  end

end
