import React, { Component } from "react";
import PropTypes from 'prop-types';
import classnames from "classnames";

/**
 * @class Icon
 * @extends {ReactComponent}
 * @description Icon class for themify icons. Replacement for Semantic ui Icon class
 */
class Icon extends Component {
    render() {
        var iconClass = classnames("icon ti-icon ti-" + this.props.name + " " + this.props.className, {
            big: this.props.big,
            large: this.props.large,
            close: this.props.close,
            circular: this.props.circular,
            tiInverted: this.props.inverted
        });

        return (
            <i
                aria-hidden={true}
                className={this.props.close ? iconClass.replace("icon", "") : iconClass}
                onClick={this.props.onClick}
                style={this.props.style}
            />
        );
    }
}

Icon.propTypes = {
    /** {String} Name of the of the icon */
    name: PropTypes.string,
    /** {boolean} Icon size big */
    big: PropTypes.boolean,
    /** {boolean}  Icon size large */
    large: PropTypes.boolean,
    /** {boolean}  Is the icon a close icon */
    close: PropTypes.boolean,
    /** {boolean}  Is the icon circular (round) */
    circular: PropTypes.boolean,
    /** {boolean} Is the icon color inverted */
    tiInverted: PropTypes.boolean,
}


export default Icon;