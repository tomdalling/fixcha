RSpec.describe Fixcha do
  subject { repo.fixcha('text', 'doctor.txt') }
  let(:repo) {
    Fixcha::Repo.new(
      base_path: [__dir__, 'fixtures'],
      content_type_repo: content_type_repo
    )
  }
  let(:content_type_repo) { nil }

  it 'can read whole files' do
    expect(subject.read).to eq("Why not Zoidberg?\n")
  end

  it 'has a Pathname' do
    expect(subject.path).to eq(Pathname.new("spec/fixtures/text/doctor.txt").realpath)
  end

  it 'can open a File' do
    subject.open do |f|
      expect(f.read).to eq("Why not Zoidberg?\n")
    end

    f = subject.open
    expect(f.read).to eq("Why not Zoidberg?\n")
    f.close
  end

  it 'implements #to_path to be compatible with File.open etc' do
    expect(subject.to_path).to eq(subject.path.to_path)
  end

  describe '#to_upload' do
    let(:content_type_repo) {
      Fixcha::ContentTypeRepo.new(
        baggins: 'rings/lord',
      )
    }

    it 'can make a Rack::Test::UploadedFile' do
      upload = repo.fixcha('crazy/bilbo.baggins').to_upload

      expect(upload).to be_a(Rack::Test::UploadedFile)
      expect(upload).to have_attributes(
        content_type: 'rings/lord',
        original_filename: 'bilbo.baggins',
      )
      expect(upload.read).to eq("my precious\n")
    end

    it "defaults to 'application/octet-stream' for unrecognised extensions" do
      expect(repo.fixcha('crazy/no_extension').content_type)
        .to eq('application/octet-stream')
      expect(repo.fixcha('crazy/whatever.ffasfasfa').content_type)
        .to eq('application/octet-stream')
    end

    it 'allows the content type to be specified explicitly' do
      subject = repo.fixcha('crazy/no_extension', content_type: 'application/zip')
      expect(subject.to_upload.content_type).to eq('application/zip')
    end
  end

end

RSpec.describe Fixcha::ContentTypeRepo do
  {
    txt: 'text/plain',
    png: 'image/png',
    jpg: 'image/jpeg',
    jpeg: 'image/jpeg',
    gif: 'image/gif',
    pdf: 'application/pdf',
    svg: 'image/svg+xml',
  }.each do |ext, content_type|
    it "comes with a default content type for '*.#{ext}' files" do
      expect(subject.("whatever.#{ext}")).to eq(content_type)
    end
  end
end
