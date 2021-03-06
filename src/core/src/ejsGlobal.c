/**
    ejsGlobal.c - Global functions and variables

    Copyright (c) All Rights Reserved. See details at the end of the file.
 */

/********************************** Includes **********************************/

#include    "ejs.h"

/*********************************** Locals ***********************************/
/*  
    Assert a condition is true.
    static function assert(condition: Boolean): Boolean
 */
static EjsBoolean *g_assert(Ejs *ejs, EjsObj *vp, int argc, EjsObj **argv)
{
    EjsFrame        *fp;
    wchar           *source;
    EjsBoolean      *b;

    if (argc == 0) {
        b = ESV(false);
    } else {
        if (!ejsIs(ejs, argv[0], Boolean)) {
            b = (EjsBoolean*) ejsCast(ejs, argv[0], Boolean);
        } else {
            b = (EjsBoolean*) argv[0];
        }
    }
    assert(b);

    if (b == 0 || !b->value) {
        fp = ejs->state->fp;
        if (ejsGetDebugInfo(ejs, (EjsFunction*) fp, fp->pc, NULL, NULL, &source) >= 0) {
            ejsThrowAssertError(ejs, "%w", source);
        } else {
            ejsThrowAssertError(ejs, "Assertion error");
        }
        return 0;
    }
    return ESV(true);
}


/*  
    function blend(dest: Object, src: Object, options = null): Object
 */
static EjsObj *g_blend(Ejs *ejs, EjsObj *unused, int argc, EjsObj **argv)
{
    EjsObj      *src, *dest, *options;
    int         flags;

    options = (argc >= 3) ? argv[2] : 0;
    if (options) {
        flags = 0;
        /* Default to false */
        flags |= ejsGetPropertyByName(ejs, options, EN("combine")) == ESV(true) ? EJS_BLEND_COMBINE : 0;
        flags |= ejsGetPropertyByName(ejs, options, EN("functions")) == ESV(true) ? EJS_BLEND_FUNCTIONS : 0;
        flags |= ejsGetPropertyByName(ejs, options, EN("trace")) == ESV(true) ? EJS_BLEND_TRACE : 0;
        flags |= ejsGetPropertyByName(ejs, options, EN("public")) == ESV(true) ? EJS_BLEND_PUBLIC : 0;

        /* Default to true */
        flags |= ejsGetPropertyByName(ejs, options, EN("overwrite")) == ESV(false) ? 0 : EJS_BLEND_OVERWRITE;
        flags |= ejsGetPropertyByName(ejs, options, EN("subclass")) == ESV(false) ? 0 : EJS_BLEND_SUBCLASSES;
        flags |= ejsGetPropertyByName(ejs, options, EN("deep")) == ESV(false) ? 0 : EJS_BLEND_DEEP;
    } else {
        flags = EJS_BLEND_DEEP | EJS_BLEND_OVERWRITE | EJS_BLEND_SUBCLASSES;
    }
    dest = argv[0];
    src = argv[1];
    ejsBlendObject(ejs, dest, src, flags);
    return dest;
}


/*  
    Clone the base class. Used by Record.es
    static function cloneBase(klass: Type): Void
 */
static EjsObj *g_cloneBase(Ejs *ejs, EjsObj *ignored, int argc, EjsObj **argv)
{
    EjsType     *type;
    
    assert(argc == 1);
    
    type = (EjsType*) argv[0];
    type->baseType = ejsClone(ejs, type->baseType, 0);
    return 0;
}


/*  
    function eval(script: String, cache: String = null): String
 */
static EjsObj *g_eval(Ejs *ejs, EjsObj *unused, int argc, EjsObj **argv)
{
    EjsString   *script;
    cchar       *cache;

    script = (EjsString*) argv[0];
    if (argc < 2 || ejsIs(ejs, argv[1], Null)) {
        cache = NULL;
    } else {
        cache = ejsToMulti(ejs, argv[1]);
    }
    if (ejsLoadScriptLiteral(ejs, script, cache, EC_FLAGS_NO_OUT | EC_FLAGS_DEBUG | EC_FLAGS_THROW | EC_FLAGS_VISIBLE) < 0) {
        return 0;
    }
    return ejs->result;
}


/*  
    Get the hash code for the object.
    function hashcode(o: Object): Number
 */
static EjsNumber *g_hashcode(Ejs *ejs, EjsObj *vp, int argc, EjsObj **argv)
{
    assert(argc == 1);
    return ejsCreateNumber(ejs, (MprNumber) PTOL(argv[0]));
}


/*  
    Load a script or module. Name should have an extension. Name will be located according to the EJSPATH search strategy.

    static function load(filename: String, options: Object): void

    options = { cache: String|Path, reload: true }
 */
static EjsObj *g_load(Ejs *ejs, EjsObj *unused, int argc, EjsObj **argv)
{
    EjsObj      *options, *vp;
    cchar       *path, *cache, *cp;
    int         reload;

    cache = 0;
    reload = 1;
    path = ejsToMulti(ejs, argv[0]);
    options = (argc >= 2) ? argv[1] : 0;

    if (options) {
        if ((vp = ejsGetPropertyByName(ejs, options, EN("cache"))) != 0) {
            cache = ejsToMulti(ejs, ejsToString(ejs, vp));
        }
        reload = ejsGetPropertyByName(ejs, options, EN("reload")) == ESV(true);
    }
    if ((cp = strrchr(path, '.')) != NULL && strcmp(cp, EJS_MODULE_EXT) != 0) {
        if (ejs->service->loadScriptFile == 0) {
            ejsThrowIOError(ejs, "load: Compiling is not enabled for %s", path);
        } else {
            return (ejs->service->loadScriptFile)(ejs, path, cache);
        }
    } else {
        ejsLoadModule(ejs, ejsCreateStringFromAsc(ejs, path), -1, -1, (reload) ? EJS_LOADER_RELOAD : 0);
        return (ejs->exception) ? 0 : ejs->result;
    }
    return 0;
}


/*  
    Compute an MD5 checksum
    static function md5(name: String): String
 */
static EjsString *g_md5(Ejs *ejs, EjsObj *unused, int argc, EjsObj **argv)
{
    EjsString   *str;
    char        *hash;

    str = (EjsString*) argv[0];
    hash = mprGetMD5WithPrefix(ejsToMulti(ejs, str), str->length, NULL);
    return ejsCreateStringFromAsc(ejs, hash);
}


static void setBlendProperty(Ejs *ejs, EjsObj *obj, EjsName name, EjsAny *value)
{
    if (ejsSetPropertyByName(ejs, obj, name, value) < 0) {
        ejsThrowArgError(ejs, "Cannot set property \"%@\"", name.name);
    }
}

/*  
    Merge one object into another. This is useful for inheriting and optionally overwriting option hashes (among other
    things). The blending is done at the primitive property level. If overwrite is true, the property is replaced. If
    overwrite is false, the property will be added if it does not already exist
 */
PUBLIC int ejsBlendObject(Ejs *ejs, EjsObj *dest, EjsObj *src, int flags)
{
    EjsTrait    *trait;
    EjsObj      *vp, *dp, *item;
    EjsName     qname, trimmedName;
    EjsArray    *ap;
    char        *str;
    int         i, j, count, start, deep, functions, overwrite, privateProps, trace, kind, combine, cflags;

    if (!ejsIsPot(ejs, dest)) {
        ejsThrowArgError(ejs, "destination is not an object");
        return -1;
    }
    if (!ejsIsDefined(ejs, src)) {
        /* Allow this - blend nothing */
        return 0;
    }
#if FUTURE
    if (!ejsIsPot(ejs, src)) {
        ejsThrowArgError(ejs, "source is not an object");
        return -1;
    }
#endif
    count = ejsGetLength(ejs, src);
    start = (flags & EJS_BLEND_SUBCLASSES) ? 0 : TYPE(src)->numInherited;
    deep = (flags & EJS_BLEND_DEEP) ? 1 : 0;
    overwrite = (flags & EJS_BLEND_OVERWRITE) ? 1 : 0;
    combine = (flags & EJS_BLEND_COMBINE) ? 1 : 0;
    functions = (flags & EJS_BLEND_FUNCTIONS) ? 1 : 0;
    privateProps = (flags & EJS_BLEND_PRIVATE) ? 1 : 0;
    trace = (flags & EJS_BLEND_TRACE) ? 1 : 0;

    for (i = start; i < count; i++) {
        if (ejs->exception) break;
        if ((trait = ejsGetPropertyTraits(ejs, src, i)) != 0) {
            if (trait->attributes & (EJS_TRAIT_DELETED | EJS_FUN_INITIALIZER | EJS_FUN_MODULE_INITIALIZER)) {
                continue;
            }
        }
        if ((vp = ejsGetProperty(ejs, src, i)) == 0) {
            continue;
        }
        if (!functions && ejsIsFunction(ejs, ejsGetProperty(ejs, src, i))) {
            continue;
        }
        qname = ejsGetPropertyName(ejs, src, i);
        if (!qname.name || !qname.space) {
            continue;
        }
        if (flags & EJS_BLEND_PUBLIC) {
            qname.space = ejsCreateStringFromAsc(ejs, "public");
        }
        if (!privateProps && ejsContainsAsc(ejs, qname.space, ",private") >= 0) {
            continue;
        }
        if (trace) {
            //  TODO - remove
            mprLog("ejs blend", 0, "Blend name %N", qname);
        }
        if (combine && qname.name) {
            cflags = flags;
            kind = qname.name->value[0];
            if (kind == '+') {
                cflags |= EJS_BLEND_ADD;
                trimmedName = N(qname.space->value, &qname.name->value[1]);
            } else if (kind == '-') {
                cflags |= EJS_BLEND_SUB;
                trimmedName = N(qname.space->value, &qname.name->value[1]);
            } else if (kind == '=') {
                cflags |= EJS_BLEND_ASSIGN;
                trimmedName = N(qname.space->value, &qname.name->value[1]);
            } else if (kind == '?') {
                cflags |= EJS_BLEND_COND_ASSIGN;
                trimmedName = N(qname.space->value, &qname.name->value[1]);
            } else {
                /* cflags |= EJS_BLEND_ASSIGN; */
                trimmedName = qname;
            }
            dp = ejsGetPropertyByName(ejs, dest, trimmedName);
            if (!dp) {
                /* Destination property missing */
                if (cflags & EJS_BLEND_SUB) {
                    continue;
                }
                if (!ejsIsPot(ejs, vp) || ejsIsFunction(ejs, vp)) {
                    setBlendProperty(ejs, dest, trimmedName, ejsClone(ejs, vp, 1));
                    continue;
                }
                dp = ejsCreateObj(ejs, TYPE(vp), 0);
                setBlendProperty(ejs, dest, trimmedName, dp);
                cflags &= ~EJS_BLEND_COND_ASSIGN;
                cflags |= EJS_BLEND_ADD;
            }
            /* Destination present */
            if (ejsIs(ejs, dp, Array)) {
                if (cflags & EJS_BLEND_ADD) {
                    if (ejsIs(ejs, vp, Array)) {
                        ap = (EjsArray*) vp;
                        for (j = 0; j < ap->length; j++) {
                            item = ejsGetProperty(ejs, ap, j);
                            if (ejsLookupItem(ejs, (EjsArray*) dp, item) < 0) {
                                ejsAddItem(ejs, (EjsArray*) dp, ejsGetProperty(ejs, ap, j));
                            }
                        }
                    } else {
                        ejsAddItem(ejs, (EjsArray*) dp, vp);
                    }
                } else if (cflags & EJS_BLEND_SUB) {
                    if (ejsIs(ejs, vp, Array)) {
                        ap = (EjsArray*) vp;
                        for (j = 0; j < ap->length; j++) {
                            ejsRemoveItem(ejs, (EjsArray*) dp, ejsGetProperty(ejs, ap, j), 1);
                        }
                    } else {
                        ejsRemoveItem(ejs, (EjsArray*) dp, ejsToString(ejs, vp), 1);
                    }
                } else if (cflags & EJS_BLEND_COND_ASSIGN) {
                    if (ejsLookupProperty(ejs, dest, trimmedName) < 0) {
                        setBlendProperty(ejs, dest, trimmedName, ejsClone(ejs, vp, deep));
                    }
                } else {
                    /* Default is a assign */
                    setBlendProperty(ejs, dest, trimmedName, ejsClone(ejs, vp, deep));
                }

            } else if (ejsIsPot(ejs, dp)) {
                if (cflags & EJS_BLEND_ASSIGN) {
                    setBlendProperty(ejs, dest, trimmedName, ejsClone(ejs, vp, deep));

                } else if (cflags & EJS_BLEND_COND_ASSIGN) {
                    if (ejsLookupProperty(ejs, dest, trimmedName) < 0) {
                        setBlendProperty(ejs, dest, trimmedName, ejsClone(ejs, vp, deep));
                    }
                } else {
                    /* Recurse and blend the elements */
                    ejsBlendObject(ejs, dp, vp, flags);
                }

            } else if (ejsIs(ejs, dp, String)) {
                if (cflags & EJS_BLEND_ADD) {
                    str = sjoin(((EjsString*) dp)->value, " ", ejsToMulti(ejs, vp), NULL);
                    setBlendProperty(ejs, dest, trimmedName, ejsCreateString(ejs, str, -1));
                    
                } else if (cflags & EJS_BLEND_SUB) {
                    str = sreplace(sclone(((EjsString*) dp)->value), ejsToMulti(ejs, vp), "");
                    if (sspace(str)) {
                        ejsDeletePropertyByName(ejs, dest, trimmedName);
                    } else {
                        setBlendProperty(ejs, dest, trimmedName, ejsCreateString(ejs, str, -1));
                    }
                    
                } else if (cflags & EJS_BLEND_COND_ASSIGN) {
                    /* Do nothing */;

                } else {
                    /* Default is assign */
                    setBlendProperty(ejs, dest, trimmedName, ejsClone(ejs, vp, deep));
                }
            } else {
                /* Assign */
                if (cflags & EJS_BLEND_COND_ASSIGN) {
                    if (ejsLookupProperty(ejs, dest, trimmedName) < 0) {
                        setBlendProperty(ejs, dest, trimmedName, ejsClone(ejs, vp, deep));
                    }
                } else if (!(cflags & EJS_BLEND_SUB)) {
                    setBlendProperty(ejs, dest, trimmedName, vp);
                }
            }

        } else {
            /* 
                NOTE: non-combine blend treats arrays as primitive types 
             */
            if (deep && !ejsIs(ejs, vp, Array) && !ejsIsXML(ejs, vp) && ejsIsPot(ejs, vp) && !ejsIsFunction(ejs, vp)) {
                if ((dp = ejsGetPropertyByName(ejs, dest, qname)) == 0 || !ejsIsPot(ejs, dp)) {
                    setBlendProperty(ejs, dest, qname, ejsClonePot(ejs, vp, deep));
                } else {
                    ejsBlendObject(ejs, dp, vp, flags);
                }
            } else {
                /*  Primitive type (including arrays) */
                if (overwrite) {
                    setBlendProperty(ejs, dest, qname, vp);
                } else if (ejsLookupProperty(ejs, dest, qname) < 0) {
                    setBlendProperty(ejs, dest, qname, vp);
                }
            }
        }
    }
    return 0;
}


/*     
    Parse the input and convert to a primitive type
    static function parse(input: String, preferredType: Type = null): void
 */
static EjsObj *g_parse(Ejs *ejs, EjsObj *unused, int argc, EjsObj **argv)
{
    EjsString   *input;
    int         preferred;

    input = (EjsString*) argv[0];
    if (argc == 2 && !ejsIsType(ejs, argv[1])) {
        ejsThrowArgError(ejs, "PreferredType argument is not a type");
        return 0;
    }
    preferred = (argc == 2) ? ((EjsType*) argv[1])->sid : -1;
    return ejsParse(ejs, input->value, preferred);
}


/*
    Parse the input as an integer
    static function parseInt(input: String, radix: Number = 10): Number
    Formats:
        [(+|-)][0][OCTAL_DIGITS]
        [(+|-)][0][(x|X)][HEX_DIGITS]
        [(+|-)][DIGITS]
 */
static EjsNumber *g_parseInt(Ejs *ejs, EjsObj *unused, int argc, EjsObj **argv)
{
    MprNumber   n;
    cchar       *str;
    int         radix, err;

    str = ejsToMulti(ejs, argv[0]);
    radix = (argc >= 2) ? ejsGetInt(ejs, argv[1]) : 0;
    while (isspace((uchar) *str)) {
        str++;
    }
    if (*str == '-' || *str == '+' || isdigit((uchar) *str)) {
        n = (MprNumber) stoiradix(str, radix, &err);
        if (err) {
            return ESV(nan);
        }
        return ejsCreateNumber(ejs, n);
    }
    return ESV(nan);
}


/*  
    Print the arguments to the standard output with a new line.
    static function print(...args): void
    DEPRECATED static function output(...args): void
 */
static EjsObj *g_printLine(Ejs *ejs, EjsObj *unused, int argc, EjsObj **argv)
{
    EjsString   *s;
    EjsObj      *args, *vp;
    cchar       *data;
    int         i, count;

    assert(argc == 1 && ejsIs(ejs, argv[0], Array));

    args = argv[0];
    count = ejsGetLength(ejs, args);

    for (i = 0; i < count; i++) {
        if ((vp = ejsGetProperty(ejs, args, i)) != 0) {
            s  = (ejsIs(ejs, vp, String)) ? (EjsString*) vp : (EjsString*) ejsToString(ejs, vp);
            if (ejs->exception) {
                return 0;
            }
            data = ejsToMulti(ejs, s);
            if (write(1, (char*) data, (int) strlen(data)) < 0) {}
            if ((i+1) < count) {
                if (write(1, " ", 1) < 0) {}
            }
        }
    }
    if (write(1, "\n", 1) < 0) {}
    return 0;
}


static EjsString *g_base64(Ejs *ejs, EjsObj *unused, int argc, EjsObj **argv)
{
    EjsString   *bstring;
    char        *str;

    bstring = ejsToString(ejs, argv[0]);
    str = ejsToMulti(ejs, bstring);
    return ejsCreateStringFromAsc(ejs, mprEncode64Block(str, bstring->length));
}


PUBLIC void ejsFreezeGlobal(Ejs *ejs)
{
    EjsTrait    *trait;
    int         i;

    for (i = 0; i < ES_global_NUM_CLASS_PROP; i++) {
        if ((trait = ejsGetPropertyTraits(ejs, ejs->global, i)) != 0) {
            ejsSetPropertyTraits(ejs, ejs->global, i, NULL, trait->attributes | EJS_TRAIT_READONLY | EJS_TRAIT_FIXED);
        }
    }
}


PUBLIC void ejsCreateGlobalNamespaces(Ejs *ejs)
{
    ejsAddImmutable(ejs, S_iteratorSpace, EN("iterator"), 
        ejsCreateNamespace(ejs, ejsCreateStringFromAsc(ejs, EJS_ITERATOR_NAMESPACE)));
    ejsAddImmutable(ejs, S_publicSpace, EN("public"), 
        ejsCreateNamespace(ejs, ejsCreateStringFromAsc(ejs, EJS_PUBLIC_NAMESPACE)));
    ejsAddImmutable(ejs, S_ejsSpace, EN("ejs"), 
        ejsCreateNamespace(ejs, ejsCreateStringFromAsc(ejs, EJS_EJS_NAMESPACE)));
    ejsAddImmutable(ejs, S_emptySpace, EN("empty"), 
        ejsCreateNamespace(ejs, ejsCreateStringFromAsc(ejs, EJS_EMPTY_NAMESPACE)));
}


PUBLIC void ejsDefineGlobalNamespaces(Ejs *ejs)
{
    /*  
        Order matters here. This is the (reverse) order of lookup.
        Empty is first to maximize speed of searching dynamic properties. Ejs second to maximize builtin lookups.
     */
    ejsAddNamespaceToBlock(ejs, ejs->global, ESV(iteratorSpace));
    ejsAddNamespaceToBlock(ejs, ejs->global, ESV(publicSpace));
    ejsAddNamespaceToBlock(ejs, ejs->global, ESV(ejsSpace));
    ejsAddNamespaceToBlock(ejs, ejs->global, ESV(emptySpace));
}


PUBLIC void ejsConfigureGlobalBlock(Ejs *ejs)
{
    EjsBlock    *block;

    block = (EjsBlock*) ejs->global;
    assert(block);
    
    ejsSetProperty(ejs, ejs->global, ES_global, ejs->global);
    ejsSetProperty(ejs, ejs->global, ES_void, ESV(Void));
    ejsSetProperty(ejs, ejs->global, ES_undefined, ESV(undefined));
    ejsSetProperty(ejs, ejs->global, ES_null, ESV(null));
    ejsSetProperty(ejs, ejs->global, ES_global, ejs->global);
    ejsSetProperty(ejs, ejs->global, ES_NegativeInfinity, ESV(negativeInfinity));
    ejsSetProperty(ejs, ejs->global, ES_Infinity, ESV(infinity));
    ejsSetProperty(ejs, ejs->global, ES_NaN, ESV(nan));
    ejsSetProperty(ejs, ejs->global, ES_double, ESV(Number));
    ejsSetProperty(ejs, ejs->global, ES_num, ESV(Number));
    ejsSetProperty(ejs, ejs->global, ES_boolean, ESV(Boolean));
    ejsSetProperty(ejs, ejs->global, ES_string, ESV(String));
    ejsSetProperty(ejs, ejs->global, ES_true, ESV(true));
    ejsSetProperty(ejs, ejs->global, ES_false, ESV(false));

    ejsBindFunction(ejs, block, ES_assert, g_assert);
    ejsBindFunction(ejs, block, ES_cloneBase, g_cloneBase);
    ejsBindFunction(ejs, block, ES_eval, g_eval);
    ejsBindFunction(ejs, block, ES_hashcode, g_hashcode);
    ejsBindFunction(ejs, block, ES_load, g_load);
    ejsBindFunction(ejs, block, ES_md5, g_md5);
    ejsBindFunction(ejs, block, ES_blend, g_blend);
    ejsBindFunction(ejs, block, ES_parse, g_parse);
    ejsBindFunction(ejs, block, ES_parseInt, g_parseInt);
    ejsBindFunction(ejs, block, ES_print, g_printLine);
    ejsBindFunction(ejs, block, ES_base64, g_base64);
}


/*
    @copy   default

    Copyright (c) Embedthis Software. All Rights Reserved.

    This software is distributed under commercial and open source licenses.
    You may use the Embedthis Open Source license or you may acquire a 
    commercial license from Embedthis Software. You agree to be fully bound
    by the terms of either license. Consult the LICENSE.md distributed with
    this software for full details and other copyrights.

    Local variables:
    tab-width: 4
    c-basic-offset: 4
    End:
    vim: sw=4 ts=4 expandtab

    @end
 */
