import React, { Component } from "react";
import classnames from "classnames";

/**
 * @class Icon
 * @extends {Component}
 * @description Icon class for themify icons. Replacement for semantic ui Icon class
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

export default Icon;