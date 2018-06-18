RSpec.describe ReservationsHandler, type: :service do
  let(:user) { User.new }
  let(:book) { Book.new }

  subject { described_class.new(user, book) }

  describe '#reserve' do
    before {
      allow(book).to receive(:can_reserve?).with(user).and_return(can_reserve)
    }

    context 'without available book' do
      let(:can_reserve) { false }
      it {
        expect(subject.reserve).to be_nil
      }
    end

    context 'with available book ' do
      let(:can_reserve) { true }
      it {
        expect(subject.reserve).to be_instance_of(Reservation)
      }
    end
  end
end