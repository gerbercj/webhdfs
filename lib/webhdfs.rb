require 'json'
require 'net/http'

module WebHDFS
  class Client

    attr_reader :user, :host, :port

    REST_PREFIX = '/webhdfs/v1'

    def initialize(user, host, port=50070)
      @user = user
      @host = host
      @port = port
    end

    def append(path, data, opts={})
      opts = allowed_opts(opts, %i(buffersize))
      result = request('POST', path, 'APPEND', opts, data)
      result.body
    end

    def cat(path, opts={})
      opts = allowed_opts(opts, %i(offset length buffersize))
      result = request('GET', path, 'OPEN', opts)
      result.body
    end

    def create(path, data, opts={})
      opts = allowed_opts(opts, %i(overwrite blocksize replication permission buffersize))
      result = request('PUT', path, 'CREATE', opts, data)
      JSON.parse(result.body) unless result.body.empty?
    end

    def home_dir()
      result = request('GET', '/', 'GETHOMEDIRECTORY')
      JSON.parse(result.body)
    end

    def ls(path)
      result = request('GET', path, 'LISTSTATUS')
      JSON.parse(result.body)
    end

    def mkdir(path, opts={})
      opts = allowed_opts(opts, %i(permission))
      result = request('PUT', path, 'MKDIRS', opts)
      JSON.parse(result.body)
    end

    def mv(path, destination)
      result = request('PUT', path, 'RENAME', "&destination=#{destination}")
      JSON.parse(result.body)
    end

    def rm(path, opts={})
      opts = allowed_opts(opts, %i(recursive))
      result = request('DELETE', path, 'DELETE', opts)
      JSON.parse(result.body)
    end

    def status(path)
      result = request('GET', path, 'GETFILESTATUS')
      JSON.parse(result.body)
    end

    def summary(path)
      result = request('GET', path, 'GETCONTENTSUMMARY')
      JSON.parse(result.body)
    end
  private

    def allowed_opts(opts, valid_keys)
      allowed = valid_keys.inject('') do |result, key|
        "#{result}&#{key}=#{opts[key]}" if opts[key]
      end
    end

    def request(method, path, op, opts='', data=nil, host=host, port=port, header=nil)
      path = "#{REST_PREFIX}#{path}?user.name=#{user}&op=#{op}#{opts}" unless op.nil?
      connection = Net::HTTP.new(host, port)
      result = connection.send_request(method, path, data, header)
      case result
      when Net::HTTPSuccess
        result
      when Net::HTTPRedirection
        uri = URI.parse(result['location'])
        request(method, "#{uri.path}?#{uri.query}", nil, nil, data, host, uri.port, {'Content-Type' => 'application/octet-stream'})
      when Net::HTTPForbidden
        raise result.to_s
      else
        result
      end
    end
  end
end
