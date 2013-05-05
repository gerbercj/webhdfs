require 'spec_helper'

describe WebHDFS::Client do
  let(:client)    { WebHDFS::Client.new('cloudera', '192.168.186.146') }
  let(:root)      { '/user/cloudera' }
  let(:test_path) { "#{root}/_test" }
  
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
      client.ls(root)['FileStatuses']['FileStatus'].select do |file|
        file['permission'] == '750' if file['pathSuffix'] == '_test'
      end.length.should == 1
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

  describe '#summary' do
    it "should return a directory's summary" do
      client.summary(root).keys.should == ['ContentSummary']
    end
  end
end

def count_nodes(path, name)
  client.ls(path)['FileStatuses']['FileStatus'].select do |file|
    file['pathSuffix'] == name
  end.length
end

def node_type(path)
  client.status(path)['FileStatus']['type']
end
