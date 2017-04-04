import { connect } from 'react-redux'
import Mailing from '../components/mailing'

const mapStateToProps = (state) => {
  return {
    mailings: state.mailings
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
  }
}

const LastMailing = connect(
  mapStateToProps,
  mapDispatchToProps
)(Mailing)

export default LastMailing
