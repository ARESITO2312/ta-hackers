# frozen_string_literal: true

module Hackers
  module Network
    ##
    # Player
    class Player < Dataset
      attr_reader :datetime, :tutorial, :profile,
                  :shield, :readme, :skins, :net,
                  :programs, :queue, :logs

      def initialize(*)
        super

        @net = Network.new
        @profile = Profile.new
        @programs = Programs.new(@api)
        @queue = Queue.new(@api, self)
        @skins = Skins.new
        @shield = Shield.new
        @logs = Logs.new(self)
        @readme = ReadmePlayer.new(@api)
      end

      def load
        @raw_data = @api.net
        parse
      end

      private

      def parse
        data = Serializer.parseData(@raw_data)

        @datetime = data.dig(10, 0, 0)
        @tutorial = data.dig(5, 0, 0).to_i

        @net.parse(data.dig(0), data.dig(1))
        @profile.parse(data.dig(2, 0))
        @programs.parse(data.dig(3))
        @queue.parse(data.dig(4))
        @skins.parse(data.dig(6))
        @shield.parse(data.dig(8, 0))
        @logs.parse(data.dig(9))
        @readme.parse(data.dig(11, 0))
      end
    end

    ##
    # Target
    class Target < Dataset
      attr_reader :net, :profile, :readme

      def initialize(*)
        super

        @net = Network.new
        @profile = Profile.new
        @readme = Readme.new(@api)
      end

      def attack(id)
      end

      def attack_test(id)
        @raw_data = @api.attack_net_test(id)
        parse
      end

      private

      def parse
        data = Serializer.parseData(@raw_data)

        @net.parse(data.dig(0), data.dig(1))
        @profile.parse(data.dig(2, 0))
        @readme.parse(data.dig(5, 0))
      end
    end

    ##
    # Network
    class Network
      include Enumerable

      def initialize
        @nodes = []
      end

      def each(&block)
        @nodes.each(&block)
      end

      def node(id)
        @nodes.detect { |n| n.id == id }
      end

      def parse(data_nodes, data_topology)
        topology = {}
        unless data_topology.empty?
          coords, rels, list = data_topology.dig(0, 1).split('|', 3)
          coords = coords.split('_')

          list = list.split('_').map(&:to_i)
          list.each_with_index do |id, i|
            topology[id] = {}
            topology[id][:rels] = []
            x, y, z = coords[i].split('*', 3).map(&:to_i)
            topology[id][:x] = x
            topology[id][:y] = y
            topology[id][:z] = z
          end

          rels = rels.split('_')
          rels.each do |rel|
            a, b = rel.split('*', 2).map(&:to_i)
            topology[list[a]][:rels] << list[b]
          end
        end

        @nodes.clear
        data_nodes.each do |record|
          node = NodeTypes.node(record[2].to_i)
          @nodes << node.new(record, topology)
        end
      end
    end

    ##
    # Programs
    class Programs
      include Enumerable

      def initialize(api)
        @api = api

        @programs = []
      end

      def each(&block)
        @programs.each(&block)
      end

      def exist?(program)
        @programs.any? { |p| p.id == program }
      end

      def get(program)
        @programs.detect { |p| p.id == program }
      end

      def edit(type, amount)
        program = @programs.detect { |p| p.type == type }
        return if program.nil?

        program.amount = amount
      end

      def create(type)
        raw_data = @api.create_program(type)
        data = Serializer.parseData(raw_data)

        id = data.dig(0, 0, 0).to_i
        program = ProgramTypes.program(type)
        @programs << program.new(@api, self, id, type)
      end

      def update
        raw_data = @api.delete_program(generate)
        raw_data.split(';') do |data|
          type, amount = data.split(',', 2).map(&:to_i)
          each do |p|
            p.amount = amount if p.type == type
          end
        end
      end

      def generate
        @programs.map { |p| "#{p.type},#{p.amount};" }.join
      end

      def parse(data)
        @programs.clear
        data.each do |record|
          program = ProgramTypes.program(record[2].to_i)
          @programs << program.new(@api, self)
          @programs.last.parse(record)
        end
      end
    end

    ##
    # Profile
    class Profile
      attr_reader :id, :name, :experience,
                  :rank, :x, :y, :country, :skin,
                  :builders

      attr_accessor :money, :bitcoins, :credits

      def parse(data)
        @id = data[0].to_i
        @name = data[1]
        @money = data[2].to_i
        @bitcoins = data[3].to_i
        @credits = data[4].to_i
        @experience = data[5].to_i
        @rank = data[9].to_i
        @builders = data[10].to_i
        @x = data[11].to_i
        @y = data[12].to_i
        @country = data[13].to_i
        @skin = data[14].to_i
      end
    end

    ##
    # Shield
    class Shield
      attr_reader :type, :time

      def installed?
        !@type.zero?
      end

      def parse(data)
        @type = data[0].to_i
        @time = data[1].to_i
      end
    end

    ##
    # Logs
    class Logs
      include Enumerable

      Record = Struct.new(
        :id,
        :datetime,
        :attacker_id,
        :attacker_name,
        :attacker_country,
        :attacker_level,
        :target_id,
        :target_name,
        :target_country,
        :target_level,
        :programs,
        :money,
        :bitcoins,
        :success,
        :rank,
        :test
      )

      Program = Struct.new(:type, :amount)

      attr_reader :logs

      def initialize(player)
        @player = player
        @logs = []
      end

      def hacks
        @logs.select { |r| r.attacker_id == @player.profile.id }
      end

      def security
        @logs.select { |r| r.target_id == @player.profile.id }
      end

      def parse(data)
        @logs.clear
        data.each do |record|
          programs = []
          programs_data = record[7].split(':')
          0.step(programs_data.length - 1, 2) do |i|
            programs << Program.new(programs_data[i].to_i, programs_data[i + 1].to_i)
          end

          @logs << Record.new(
            record[0].to_i,
            record[1],
            record[2].to_i,
            record[9],
            record[11].to_i,
            record[16].to_i,
            record[3].to_i,
            record[10],
            record[12].to_i,
            record[17].to_i,
            programs,
            record[4].to_i,
            record[5].to_i,
            record[6].to_i,
            record[13].to_i,
            record[18].to_i == 1,
          )
        end
      end
    end

    ##
    # Readme
    class Readme
      include Enumerable

      def initialize(api)
        @api = api

        @messages = []
      end

      def each(&block)
        @messages.each(&block)
      end

      def message?(index)
        !@messages[index].nil?
      end

      def write(message, name = nil, index = nil)
        message.prepend("#{name}: ") unless name.nil?
        unless index.nil?
          @messages[index] = message
          return
        end

        @messages << message
      end

      def read(index)
        @messages[index]
      end

      def remove(index)
        @messages.delete_at(index)
      end

      def clear
        @messages.clear
      end

      def generate
        @messages.join(Serializer::DELIM_README)
      end

      def parse(data)
        return if data.nil?

        @messages = data[0].split(Serializer::DELIM_README)
      end
    end

    ##
    # Readme player
    class ReadmePlayer < Readme
      def update
        @api.set_readme(generate)
      end
    end

    ##
    # Queue
    class Queue
      include Enumerable

      attr_reader :sequence

      Item = Struct.new(:type, :amount, :timer)

      def initialize(api, player)
        @api = api
        @player = player

        @queue = []
        @sequence = 0
      end

      def each(&block)
        @queue.each(&block)
      end

      def add(type, amount)
        remove(type)
        @queue << Item.new(type, amount)
      end

      def remove(type)
        @queue.delete_if { |i| i.type == type }
      end

      def sync
        raw_data = @api.queue_sync(generate, @sequence)
        data = Serializer.parseData(raw_data)

        @player.programs.parse(data.dig(0))
        parse(data.dig(1))
        @player.profile.bitcoins = data.dig(2, 0, 0)

        @sequence += 1
      end

      def generate
        @queue.map { |i| "#{i.type},#{i.amount};" }.join
      end

      def parse(data)
        @queue.clear
        data.each do |record|
          @queue << Item.new(
            record[0].to_i,
            record[1].to_i,
            record[2].to_i
          )
        end
      end
    end

    ##
    # Skins
    class Skins
      include Enumerable

      Skin = Struct.new(:type)

      def initialize
        @skins = []
      end

      def empty?
        @skins.empty?
      end

      def each(&block)
        @skins.each(&block)
      end

      def parse(data)
        @skins.clear
        data.each do |record|
          @skins << Skin.new(record[0].to_i)
        end
      end
    end
  end
end
