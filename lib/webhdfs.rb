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
      result = request('APPEND', 'POST', path, opts, data)
      result.body
    end

    def cat(path, opts={})
      opts = allowed_opts(opts, %i(offset length buffersize))
      result = request('OPEN', 'GET', path, opts)
      result.body
    end

    def checksum(path)
      result = request('GETFILECHECKSUM', 'GET', path)
      JSON.parse(result.body)
    end

    def chmod(path, opts={})
      opts = allowed_opts(opts, %i(permission))
      result = request('SETPERMISSION', 'PUT', path, opts)
      result.body
    end

    def chown(path, opts={})
      opts = allowed_opts(opts, %i(owner group))
      result = request('SETOWNER', 'PUT', path, opts)
      result.body
    end

    def create(path, data, opts={})
      opts = allowed_opts(opts, %i(overwrite blocksize replication permission buffersize))
      result = request('CREATE', 'PUT', path, opts, data)
      JSON.parse(result.body) unless result.body.empty?
    end

    def home_dir()
      result = request('GETHOMEDIRECTORY', 'GET')
      JSON.parse(result.body)
    end

    def ls(path)
      result = request('LISTSTATUS', 'GET', path)
      JSON.parse(result.body)
    end

    def mkdir(path, opts={})
      opts = allowed_opts(opts, %i(permission))
      result = request('MKDIRS', 'PUT', path, opts)
      JSON.parse(result.body)
    end

    def mv(path, destination)
      result = request('RENAME', 'PUT', path, "&destination=#{destination}")
      JSON.parse(result.body)
    end

    def replication(path, opts={})
      opts = allowed_opts(opts, %i(replication))
      result = request('SETREPLICATION', 'PUT', path, opts)
      JSON.parse(result.body)
    end

    def rm(path, opts={})
      opts = allowed_opts(opts, %i(recursive))
      result = request('DELETE', 'DELETE', path, opts)
      JSON.parse(result.body)
    end

    def status(path)
      result = request('GETFILESTATUS', 'GET', path)
      JSON.parse(result.body)
    end

    def summary(path)
      result = request('GETCONTENTSUMMARY', 'GET', path)
      JSON.parse(result.body)
    end
  private

    def allowed_opts(opts, valid_keys)
      allowed = valid_keys.inject('') do |result, key|
        if opts[key]
          "#{result}&#{key}=#{opts[key]}"
        else
          result
        end
      end
    end

    def request(op, method, path='/', opts='', data=nil, host=host, port=port, header=nil)
      path = "#{REST_PREFIX}#{path}?user.name=#{user}&op=#{op}#{opts}" unless op.nil?
      connection = Net::HTTP.new(host, port)
      result = connection.send_request(method, path, data, header)
      case result
      when Net::HTTPSuccess
        result
      when Net::HTTPRedirection
        uri = URI.parse(result['location'])
        request(nil, method, "#{uri.path}?#{uri.query}", nil, data, host, uri.port, {'Content-Type' => 'application/octet-stream'})
      when Net::HTTPForbidden
        raise result.to_s
      else
        result
      end
    end
  end
end
