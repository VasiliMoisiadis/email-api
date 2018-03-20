RSpec.describe Backend do
  it "has a version number" do
    expect(Backend::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
