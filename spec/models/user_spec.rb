require 'rails_helper'

describe User do
  let(:vendor){ create(:sms_vendor) }
  let(:account){vendor.accounts.create(name: 'name')}
  let(:user){account.users.create(email: 'foo@evotest.govdelivery.com', password: "schwoop")}
  subject { user }

  context "when valid" do
    specify { expect(subject.valid?).to eq(true) }
    specify { expect(subject.authentication_tokens.count).to eq(1) }
  end
  
  context "when email is empty" do
    before { subject.email = nil }
    specify { expect(subject.valid?).to eq(false) }
  end

  context "when email is invalid" do
    before { subject.email = "fooper" }
    specify { expect(subject.valid?).to eq(false) }
  end
  
  context "when account is nil" do
    before { subject.account = nil }
    specify { expect(subject.valid?).to eq(false) }
  end

  it "should find users by token" do
    expect(User.with_token(user.authentication_tokens.first.token)).to eq(user)
  end
end
