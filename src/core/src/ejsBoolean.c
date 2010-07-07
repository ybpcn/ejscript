/**
    ejsBoolean.c - Boolean native class

    Copyright (c) All Rights Reserved. See details at the end of the file.
 */

/********************************** Includes **********************************/

#include    "ejs.h"

/******************************************************************************/
/*
    Cast the operand to a primitive type

    function cast(type: Type) : Object
 */

static EjsObj *castBooleanVar(Ejs *ejs, EjsBoolean *vp, EjsType *type)
{
    mprAssert(ejsIsBoolean(vp));

    switch (type->id) {

    case ES_Number:
        return (EjsObj*) ((vp->value) ? ejs->oneValue: ejs->zeroValue);

    case ES_String:
        return (EjsObj*) ejsCreateString(ejs, (vp->value) ? "true" : "false");

    default:
        ejsThrowTypeError(ejs, "Can't cast to this type");
        return 0;
    }
}


/*
    Coerce operands for invokeOperator
 */
static EjsObj *coerceBooleanOperands(Ejs *ejs, EjsObj *lhs, int opcode, EjsObj *rhs)
{
    switch (opcode) {

    case EJS_OP_ADD:
        if (ejsIsUndefined(rhs)) {
            return (EjsObj*) ejs->nanValue;
        } else if (ejsIsNull(rhs) || ejsIsNumber(rhs) || ejsIsDate(rhs)) {
            return ejsInvokeOperator(ejs, (EjsObj*) ejsToNumber(ejs, lhs), opcode, rhs);
        } else {
            return ejsInvokeOperator(ejs, (EjsObj*) ejsToString(ejs, lhs), opcode, rhs);
        }
        break;

    case EJS_OP_AND: case EJS_OP_DIV: case EJS_OP_MUL: case EJS_OP_OR: case EJS_OP_REM:
    case EJS_OP_SHL: case EJS_OP_SHR: case EJS_OP_SUB: case EJS_OP_USHR: case EJS_OP_XOR:
        return ejsInvokeOperator(ejs, (EjsObj*) ejsToNumber(ejs, lhs), opcode, rhs);

    case EJS_OP_COMPARE_LE: case EJS_OP_COMPARE_LT:
    case EJS_OP_COMPARE_GE: case EJS_OP_COMPARE_GT:
    case EJS_OP_COMPARE_EQ: case EJS_OP_COMPARE_NE:
        if (ejsIsString(rhs)) {
            return ejsInvokeOperator(ejs, (EjsObj*) ejsToString(ejs, lhs), opcode, rhs);
        }
        return ejsInvokeOperator(ejs, (EjsObj*) ejsToNumber(ejs, lhs), opcode, rhs);

    case EJS_OP_COMPARE_STRICTLY_NE:
        return (EjsObj*) ejs->trueValue;

    case EJS_OP_COMPARE_STRICTLY_EQ:
        return (EjsObj*) ejs->falseValue;

    /*
        Unary operators
     */
    case EJS_OP_LOGICAL_NOT: case EJS_OP_NOT: case EJS_OP_NEG:
        return 0;

    case EJS_OP_COMPARE_NOT_ZERO:
    case EJS_OP_COMPARE_TRUE:
        return (EjsObj*) (((EjsBoolean*) lhs)->value ? ejs->trueValue: ejs->falseValue);

    case EJS_OP_COMPARE_ZERO:
    case EJS_OP_COMPARE_FALSE:
        return (EjsObj*) (((EjsBoolean*) lhs)->value ? ejs->falseValue : ejs->trueValue);

    case EJS_OP_COMPARE_UNDEFINED:
    case EJS_OP_COMPARE_NULL:
        return (EjsObj*) ejs->falseValue;

    default:
        ejsThrowTypeError(ejs, "Opcode %d not valid for type %s", opcode, lhs->type->qname.name);
        return ejs->undefinedValue;
    }
}


/*
    Run an operator on the operands
 */
static EjsObj *invokeBooleanOperator(Ejs *ejs, EjsBoolean *lhs, int opcode, EjsBoolean *rhs)
{
    EjsObj      *result;

    if (rhs == 0 || lhs->obj.type != rhs->obj.type) {
        if (!ejsIsA(ejs, (EjsObj*) lhs, ejs->booleanType) || !ejsIsA(ejs, (EjsObj*) rhs, ejs->booleanType)) {
            if ((result = coerceBooleanOperands(ejs, (EjsObj*) lhs, opcode, (EjsObj*) rhs)) != 0) {
                return result;
            }
        }
    }

    /*
        Types now match
     */
    switch (opcode) {

    case EJS_OP_COMPARE_EQ: case EJS_OP_COMPARE_STRICTLY_EQ:
        return (EjsObj*) ((lhs->value == rhs->value) ? ejs->trueValue: ejs->falseValue);

    case EJS_OP_COMPARE_NE: case EJS_OP_COMPARE_STRICTLY_NE:
        return (EjsObj*) ((lhs->value != rhs->value) ? ejs->trueValue: ejs->falseValue);

    case EJS_OP_COMPARE_LT:
        return (EjsObj*) ((lhs->value < rhs->value) ? ejs->trueValue: ejs->falseValue);

    case EJS_OP_COMPARE_LE:
        return (EjsObj*) ((lhs->value <= rhs->value) ? ejs->trueValue: ejs->falseValue);

    case EJS_OP_COMPARE_GT:
        return (EjsObj*) ((lhs->value > rhs->value) ? ejs->trueValue: ejs->falseValue);

    case EJS_OP_COMPARE_GE:
        return (EjsObj*) ((lhs->value >= rhs->value) ? ejs->trueValue: ejs->falseValue);

    case EJS_OP_COMPARE_NOT_ZERO:
        return (EjsObj*) ((lhs->value) ? ejs->trueValue: ejs->falseValue);

    case EJS_OP_COMPARE_ZERO:
        return (EjsObj*) ((lhs->value == 0) ? ejs->trueValue: ejs->falseValue);

    case EJS_OP_COMPARE_UNDEFINED:
    case EJS_OP_COMPARE_NULL:
        return (EjsObj*) ejs->falseValue;

    case EJS_OP_COMPARE_FALSE:
        return (EjsObj*) ((lhs->value) ? ejs->falseValue: ejs->trueValue);

    case EJS_OP_COMPARE_TRUE:
        return (EjsObj*) ((lhs->value) ? ejs->trueValue: ejs->falseValue);

    /*
        Unary operators
     */
    case EJS_OP_NEG:
        return (EjsObj*) ejsCreateNumber(ejs, - lhs->value);

    case EJS_OP_LOGICAL_NOT:
        return (EjsObj*) ejsCreateBoolean(ejs, !lhs->value);

    case EJS_OP_NOT:
        return (EjsObj*) ejsCreateBoolean(ejs, ~lhs->value);

    /*
        Binary operations
     */
    case EJS_OP_ADD:
        return (EjsObj*) ejsCreateBoolean(ejs, lhs->value + rhs->value);

    case EJS_OP_AND:
        return (EjsObj*) ejsCreateBoolean(ejs, lhs->value & rhs->value);

    case EJS_OP_DIV:
        return (EjsObj*) ejsCreateBoolean(ejs, lhs->value / rhs->value);

    case EJS_OP_MUL:
        return (EjsObj*) ejsCreateBoolean(ejs, lhs->value * rhs->value);

    case EJS_OP_OR:
        return (EjsObj*) ejsCreateBoolean(ejs, lhs->value | rhs->value);

    case EJS_OP_REM:
        return (EjsObj*) ejsCreateBoolean(ejs, lhs->value % rhs->value);

    case EJS_OP_SUB:
        return (EjsObj*) ejsCreateBoolean(ejs, lhs->value - rhs->value);

    case EJS_OP_USHR:
        return (EjsObj*) ejsCreateBoolean(ejs, lhs->value >> rhs->value);

    case EJS_OP_XOR:
        return (EjsObj*) ejsCreateBoolean(ejs, lhs->value ^ rhs->value);

    default:
        ejsThrowTypeError(ejs, "Opcode %d not implemented for type %s", opcode, lhs->obj.type->qname.name);
        return 0;
    }
}


/*********************************** Methods **********************************/
/*
    Boolean constructor.

        function Boolean(value: Boolean = null)

    If the value is omitted or 0, -1, NaN, false, null, undefined or the empty string, then set the boolean value to
    to false.
 */

static EjsObj *booleanConstructor(Ejs *ejs, EjsBoolean *bp, int argc, EjsObj **argv)
{
    mprAssert(argc == 0 || argc == 1);

    if (argc >= 1) {
        /* Change the bp value */
        bp->value = ejsToBoolean(ejs, argv[0])->value;
    }
    return (EjsObj*) bp;
}


/*********************************** Factory **********************************/

EjsBoolean *ejsCreateBoolean(Ejs *ejs, int value)
{
    return (EjsBoolean*) ((value) ? ejs->trueValue : ejs->falseValue);
}


void ejsCreateBooleanType(Ejs *ejs)
{
    EjsType     *type;
    EjsBoolean  *vp;

    type = ejs->booleanType = ejsCreateNativeType(ejs, "ejs", "Boolean", ES_Boolean, sizeof(EjsBoolean));
    type->immutable = 1;

    type->helpers.cast = (EjsCastHelper) castBooleanVar;
    type->helpers.invokeOperator = (EjsInvokeOperatorHelper) invokeBooleanOperator;

    /*
        Pre-create the only two valid instances for boolean
     */
    vp = (EjsBoolean*) ejsCreate(ejs, type, 0);
    vp->value = 1;
    ejs->trueValue = (EjsObj*) vp;

    vp = (EjsBoolean*) ejsCreate(ejs, type, 0);
    vp->value = 0;
    ejs->falseValue = (EjsObj*) vp;

    ejsSetDebugName(ejs->falseValue, "false");
    ejsSetDebugName(ejs->trueValue, "true");
}


void ejsConfigureBooleanType(Ejs *ejs)
{
    EjsType     *type;
    EjsObj      *prototype;

    type = ejsGetTypeByName(ejs, "ejs", "Boolean");
    prototype = type->prototype;

    ejsBindConstructor(ejs, type, (EjsProc) booleanConstructor);
    ejsSetProperty(ejs, ejs->global, ES_boolean, type);
    ejsSetProperty(ejs, ejs->global, ES_true, ejs->trueValue);
    ejsSetProperty(ejs, ejs->global, ES_false, ejs->falseValue);

}


/*
    @copy   default

    Copyright (c) Embedthis Software LLC, 2003-2010. All Rights Reserved.
    Copyright (c) Michael O'Brien, 1993-2010. All Rights Reserved.

    This software is distributed under commercial and open source licenses.
    You may use the GPL open source license described below or you may acquire
    a commercial license from Embedthis Software. You agree to be fully bound
    by the terms of either license. Consult the LICENSE.TXT distributed with
    this software for full details.

    This software is open source; you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by the
    Free Software Foundation; either version 2 of the License, or (at your
    option) any later version. See the GNU General Public License for more
    details at: http://www.embedthis.com/downloads/gplLicense.html

    This program is distributed WITHOUT ANY WARRANTY; without even the
    implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

    This GPL license does NOT permit incorporating this software into
    proprietary programs. If you are unable to comply with the GPL, you must
    acquire a commercial license to use this software. Commercial licenses
    for this software and support services are available from Embedthis
    Software at http://www.embedthis.com

    @end
 */
