require 'spec_helper'

describe WebHDFS::Client do
  let(:user)      { ENV['WEBHDFS_USER'] || 'hdfs' }
  let(:host)      { ENV['WEBHDFS_HOST'] || '192.168.186.146' }
  let(:client)    { WebHDFS::Client.new(user, host) }
  let(:root)      { client.home_dir['Path'] }
  let(:test_path) { "#{root}/_test" }

  before :all do
    cleaner = WebHDFS::Client.new('hdfs', '192.168.186.146')
    cleaner.rm('/user/cloudera/_test', :recursive => true)
  end

  context 'file and directory operations' do
    describe '#append' do
      after :each do
        client.rm(test_path)
      end

      it 'should append to a file' do
        client.create(test_path, '')
        client.append(test_path, 'appended')
        client.cat(test_path).should == 'appended'
      end
    end

    describe '#cat' do
      after :each do
        client.rm(test_path)
      end

      it 'should display the contents of a file' do
        client.create(test_path, 'contents')
        client.cat(test_path).should == 'contents'
      end
    end

    describe '#create' do
      after :each do
        client.rm(test_path)
      end

      it 'should create a file' do
        client.create(test_path, '')
        count_nodes(root, '_test').should == 1
        node_type(test_path).should == 'FILE'
      end
    end

    describe '#ls' do
      it 'should return folder contents' do
        client.ls(root)['FileStatuses'].should_not be_nil
      end
    end

    describe '#mkdir' do
      after :each do
        client.rm(test_path, :recursive => true)
      end

      it 'should create a directory' do
        client.mkdir(test_path)
        count_nodes(root, '_test').should == 1
        node_type(test_path).should == 'DIRECTORY'
      end

      it 'should create a directory with permissions' do
        client.mkdir(test_path, :permission => '750')
        client.status(test_path)['FileStatus']['permission'].should == '750'
      end
    end

    describe '#mv' do
      it 'should rename a file' do
        dest_path = "#{root}/_test2"
        client.create(test_path, '')
        client.mv(test_path, dest_path)
        count_nodes(root, '_test').should == 0
        count_nodes(root, '_test2').should == 1
        client.rm(dest_path)
      end

      it 'should rename a directory' do
        dest_path = "#{root}/_test2"
        client.mkdir(test_path)
        client.mv(test_path, dest_path)
        count_nodes(root, '_test').should == 0
        count_nodes(root, '_test2').should == 1
        client.rm(dest_path)
      end
    end

    describe '#rm' do
      after :each do
        client.rm(test_path, :recursive => true)
      end

      it 'should remove a file' do
        file_path = "#{root}/_test"
        client.create(file_path, '')
        client.rm(file_path)
        count_nodes(root, '_test').should == 0
      end

      it 'should remove an empty directory' do
        client.mkdir(test_path)
        client.rm(test_path)
        count_nodes(root, '_test').should == 0
      end

      it 'should not remove a directory with contents' do
        client.mkdir(test_path)
        client.mkdir("#{test_path}/_test2")
        lambda {client.rm(test_path)}.should raise_error
        count_nodes(root, '_test').should == 1
      end

      it 'should remove a directory with contents recursively' do
        client.mkdir(test_path)
        client.mkdir("#{test_path}/_test2")
        client.rm(test_path, :recursive => true)
        count_nodes(root, '_test').should == 0
      end
    end

    describe '#status' do
      it "should return a file's status" do
        client.create(test_path, '')
        node_type(test_path).should == 'FILE'
        client.rm(test_path)
      end

      it "should return a directory's status" do
        node_type(root).should == 'DIRECTORY'
      end
    end
  end

  context 'file system operations' do
    describe '#checksum' do
      after :each do
        client.rm(test_path)
      end

      it 'should be deterministic' do
        client.create(test_path, 'contents')
        client.checksum(test_path)['FileChecksum']['bytes'].should == '0000020000000000000000000702b40d10b999d851990de3da80d0d800000000'
      end
    end

    describe '#chmod' do
      after :each do
        client.rm(test_path)
      end

      it 'should change permissions on files' do
        client.create(test_path, '', :permission => 755)
        client.chmod(test_path, :permission => 600)
        client.status(test_path)['FileStatus']['permission'].should == '600'
      end

      it 'should change permissions on directories' do
        client.mkdir(test_path, :permission => 755)
        client.chmod(test_path, :permission => 600)
        client.status(test_path)['FileStatus']['permission'].should == '600'
      end
    end

    describe '#chown' do
      after :each do
        client.rm(test_path)
      end

      it 'should change owners on files' do
        client.create(test_path, '')
        client.chown(test_path, :owner => 'cloudera')
        client.status(test_path)['FileStatus']['owner'].should == 'cloudera'
      end

      it 'should change groups on files' do
        client.create(test_path, '')
        client.chown(test_path, :group => 'cloudera')
        client.status(test_path)['FileStatus']['group'].should == 'cloudera'
      end

      it 'should change owners on directories' do
        client.mkdir(test_path)
        client.chown(test_path, :owner => 'cloudera')
        client.status(test_path)['FileStatus']['owner'].should == 'cloudera'
      end

      it 'should change groups on directories' do
        client.mkdir(test_path)
        client.chown(test_path, :group => 'cloudera')
        client.status(test_path)['FileStatus']['group'].should == 'cloudera'
      end
    end

    describe '#home_dir' do
      it 'should return a path' do
        client.home_dir["Path"].should =~ /\//
      end
    end

    describe '#replication' do
      after :each do
        client.rm(test_path)
      end

      it 'should change replication for a file' do
        client.create(test_path,'')
        old_replication = client.status(test_path)['FileStatus']['replication']
        new_replication = old_replication + 1
        client.replication(test_path, :replication => new_replication)
        client.status(test_path)['FileStatus']['replication'].should == new_replication
      end
    end

    describe '#summary' do
      it "should return a directory's summary" do
        client.summary(root).keys.should == ['ContentSummary']
      end
    end

    describe '#touch' do
      after :each do
        client.rm(test_path)
      end

      it 'should update modification time' do
        client.create(test_path, '')
        old_time = client.status(test_path)['FileStatus']['modificationTime']
        new_time = old_time + 1
        client.touch(test_path, :modificationtime => new_time)
        client.status(test_path)['FileStatus']['modificationTime'].should == new_time
      end

      it 'should update access time' do
        client.create(test_path, '')
        old_time = client.status(test_path)['FileStatus']['accessTime']
        new_time = old_time + 1
        client.touch(test_path, :accesstime => new_time)
        client.status(test_path)['FileStatus']['accessTime'].should == new_time
      end
    end
  end

  # context 'delegation token operations' do
  #   let(:token) { client.get_token('hdfs') }

  #   describe '#cancel_token' do
  #     it 'should cancel the token' do
  #       client.cancel_token(token).should_not raise_error
  #     end
  #   end

  #   describe '#get_token' do
  #     it 'should get the token' do
  #       token['Token']['urlString'].should_not == ""
  #     end
  #   end

  #   describe '#renew_token' do
  #     it 'should renew the token' do
  #       client.renew_token(token)['long'].should > 0
  #     end
  #   end
  # end
end

def count_nodes(path, name)
  client.ls(path)['FileStatuses']['FileStatus'].select do |file|
    file['pathSuffix'] == name
  end.length
end

def node_type(path)
  client.status(path)['FileStatus']['type']
end
